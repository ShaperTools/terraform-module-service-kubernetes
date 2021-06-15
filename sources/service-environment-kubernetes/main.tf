resource "kubernetes_deployment" "deployment" {
  count = var.disabled ? 0 : 1

  metadata {
    name = var.service_environment_name
    labels = {
      app = var.service_environment_name
    }
    namespace = var.namespace
  }

  spec {
    replicas = var.enable_hpa ? var.hpa_configuration.min_replicas : var.desired_count

    selector {
      match_labels = {
        app = var.service_environment_name
      }
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = var.max_surge
        max_unavailable = var.max_unavailable
      }
    }

    template {
      metadata {
        labels = {
          app = var.service_environment_name
        }
      }

      spec {

        container {
          image = var.docker_image
          name  = var.service_environment_name

          dynamic "env" {
            for_each = var.environment_variables
            content {
              name  = env.value.name
              value = env.value.value

              dynamic "value_from" {
                for_each = env.value.value_from == null ? [] : [env.value.value_from]
                content {
                  dynamic "config_map_key_ref" {
                    for_each = value_from.value.config_map_key_ref
                    content {
                      key  = config_map_key_ref.value.key
                      name = config_map_key_ref.value.name
                    }
                  }
                  dynamic "field_ref" {
                    for_each = value_from.value.field_ref
                    content {
                      api_version = field_ref.value.api_version
                      field_path  = field_ref.value.field_path
                    }
                  }
                  dynamic "resource_field_ref" {
                    for_each = value_from.value.resource_field_ref
                    content {
                      container_name = resource_field_ref.value.container_name
                      resource       = resource_field_ref.value.resource
                    }
                  }
                }
              }
            }
          }

          dynamic "env" {
            for_each = var.secret_envs
            content {
              name = env.value.var_name
              value_from {
                secret_key_ref {
                  name = env.value.secret_name
                  key  = env.value.secret_key
                }
              }
            }
          }

          args = var.args

          image_pull_policy = "Always"

          resources {
            requests {
              cpu    = var.resource_requests.cpu
              memory = var.resource_requests.memory
            }
            limits {
              cpu    = var.resource_limits.cpu
              memory = var.resource_limits.memory
            }
          }

          dynamic "volume_mount" {
            for_each = var.volume_mounts
            content {
              mount_path        = volume_mount.value.mount_path
              name              = volume_mount.value.name
              read_only         = volume_mount.value.read_only
              sub_path          = volume_mount.value.sub_path
              mount_propagation = volume_mount.value.mount_propagation
            }
          }
        }

        dynamic "image_pull_secrets" {
          for_each = var.image_pull_secret_name == null ? [] : [var.image_pull_secret_name]
          content {
            name = image_pull_secrets.value
          }
        }

        dynamic "volume" {
          for_each = var.volumes
          content {
            name = volume.value.name

            dynamic "config_map" {
              for_each = volume.value.config_map == null ? [] : [volume.value.config_map]
              content {
                name = config_map.value.name

                dynamic "items" {
                  for_each = config_map.value.items
                  content {
                    key  = items.value.key
                    path = items.value.path
                  }
                }
              }
            }
          }
        }

        dynamic "volume" {
          for_each = var.nfs_volumes
          content {
            name = volume.value.volume_name
            nfs {
              path   = volume.value.nfs_path
              server = volume.value.nfs_endpoint
            }
          }
        }

        node_selector = var.node_selector
      }
    }
  }

}

resource "kubernetes_service" "service" {
  count = var.disabled ? 0 : 1

  metadata {
    name      = var.service_environment_name
    namespace = var.namespace
  }

  spec {
    selector = {
      app = kubernetes_deployment.deployment[0].metadata.0.labels.app
    }

    port {
      port        = 8080
      target_port = var.port
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress" "ingress" {
  count = var.disabled ? 0 : length(var.ingresses)

  metadata {
    name      = "${var.service_environment_name}${length(var.ingresses) > 1 ? "-${count.index + 1}" : ""}"
    namespace = var.namespace
    annotations = merge(
      { "kubernetes.io/ingress.class" = "nginx" },
      var.mergeable_ingress.enabled ? { "nginx.org/mergeable-ingress-type" = "minion" } : { "ingress.kubernetes.io/ssl-redirect" = "true" },
      var.ingresses[count.index].annotations
    )
  }

  spec {
    dynamic "rule" {
      for_each = var.ingresses[count.index].rules
      content {
        host = rule.value.host

        http {
          path {
            backend {
              service_name = kubernetes_service.service[0].metadata.0.name
              service_port = kubernetes_service.service[0].spec.0.port.0.port
            }

            path = rule.value.path
          }
        }
      }
    }

    dynamic "tls" {
      for_each = var.mergeable_ingress.enabled ? {} : { for x in var.ingresses[count.index].rules : x.tls_certificate_secret_name => x.host... }
      content {
        hosts       = tls.value
        secret_name = tls.key
      }
    }
  }
}

resource "kubectl_manifest" "master_ingress" {
  count = ! var.disabled && var.mergeable_ingress.enabled && var.mergeable_ingress.is_master ? 1 : 0

  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ${var.service_environment_name}-master
  namespace: ${var.namespace}
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.org/mergeable-ingress-type: "master"
    ingress.kubernetes.io/ssl-redirect: "true"
    ${var.mergeable_ingress.master_annotations}
spec:
  tls:
  - hosts:
    - ${var.ingresses[0].rules[0].host}
    secretName: ${var.ingresses[0].rules[0].tls_certificate_secret_name}
  rules:
  - host: ${var.ingresses[0].rules[0].host}
YAML
}

resource "kubernetes_horizontal_pod_autoscaler" "hpa" {
  count = ! var.disabled && var.enable_hpa ? 1 : 0

  metadata {
    name      = var.service_environment_name
    namespace = var.namespace
  }

  spec {
    min_replicas = var.hpa_configuration.min_replicas
    max_replicas = var.hpa_configuration.max_replicas

    scale_target_ref {
      kind        = "Deployment"
      name        = kubernetes_deployment.deployment[0].metadata.0.name
      api_version = "apps/v1"
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = var.hpa_configuration.memory_utilization
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = var.hpa_configuration.cpu_utilization
        }
      }
    }
  }
}
