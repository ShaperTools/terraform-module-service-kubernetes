variable "args" {
  type        = list(string)
  description = "Arguments to the entrypoint. The docker image's CMD is used if this is not provided."
  default     = null
}

variable "desired_count" {
  type        = number
  description = "The desired number of replicas"
}

variable "disabled" {
  type        = bool
  description = "Whether the module should be disabled or not (either \"true\" or \"false\"). This is needed to overcome the Terraform limitation that modules currently can't have a \"count\" argument."
  default     = false
}

variable "docker_image" {
  type        = string
  description = "The name & tag of the Docker image to use"
}

variable "environment_variables" {
  type = list(object({
    name  = string,
    value = string,
    value_from = object({
      config_map_key_ref = list(object({ key = string, name = string }))
      field_ref          = list(object({ api_version = string, field_path = string }))
      resource_field_ref = list(object({ container_name = string, resource = string }))
    })
  }))
  description = "A list of environment variables to set within the pod's container"
  default     = []
}

variable "secret_envs" {
  type        = list(object({ var_name = string, secret_name = string, secret_key = string }))
  description = "A list of secret environment variables to be taken from k8s secret"
  default     = []
}

variable "image_pull_secret_name" {
  type        = string
  description = "The name of the Kubernetes secret to use when pulling the Docker image"
  default     = null
}

variable "ingresses" {
  type = list(object({
    annotations = map(string),
    rules       = list(object({ host = string, path = string, tls_certificate_secret_name = string }))
  }))
  description = "The list of ingresses to create for routing traffic to the service"
}

variable "max_surge" {
  type        = string
  description = "The maximum number of pods that can be scheduled above the desired number of pods. See: https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#max_surge"
}

variable "max_unavailable" {
  type        = string
  description = "The maximum number of pods that can be unavailable during the update. See: https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#max_unavailable"
}

variable "namespace" {
  type        = string
  description = "The namespace within which to create resources"
  default     = null
}

variable "port" {
  type        = number
  description = "The port exposed by the Docker container for accessing the service"
}

variable "resource_requests" {
  type        = object({ cpu = string, memory = string })
  description = "Request for the amount of resources to reserve for each pod"
}

variable "resource_limits" {
  type        = object({ cpu = string, memory = string })
  description = "Hard resource limits for each pod"
}

variable "service_environment_name" {
  type        = string
  description = "The name of the service environment"
}

variable "volume_mounts" {
  type = list(object({
    mount_path        = string
    name              = string
    read_only         = bool
    sub_path          = string
    mount_propagation = string
  }))
  description = "Pod volumes to mount into the container's filesystem. Cannot be updated."
  default     = []
}

variable "volumes" {
  type        = list(any)
  description = "List of volumes that can be mounted by containers belonging to the pod"
  default     = []
}

variable "nfs_volumes" {
  type = list(object({
    volume_name  = string
    nfs_path     = string
    nfs_endpoint = string
  }))
  description = "Represents an NFS mounts on the host"
  default     = []
}

variable "node_selector" {
  type        = map(string)
  description = "NodeSelector should be specified for the pod to fit on a node (must match a node's labels to be scheduled on that node)"
  default     = {}
}

variable "mergeable_ingress" {
  type = object({
    enabled            = bool   # used to identify if mergeable ingress resources should be configured
    is_master          = bool   # used to identify if master ingress should be created
    master_annotations = string # custom annotations for master mergeable ingress
  })
  description = "Whether to spread the Ingress configuration for a common host"
  default = {
    enabled            = false
    is_master          = false
    master_annotations = ""
  }
}

variable "enable_hpa" {
  type        = bool
  description = "Whether to use Horizontal Pod Autoscaler"
  default     = false
}

variable "hpa_configuration" {
  type = object({
    min_replicas    = number # lower limit for the number of pods that can be set by the autoscaler
    max_replicas    = number # upper limit for the number of pods that can be set by the autoscaler
    cpu_utilization = number # target average CPU utilization (represented as a percentage of requested CPU) over all the pods
  })
  description = "Horizontal Pod Autoscaler configuration"
  default = {
    min_replicas    = 2
    max_replicas    = 10
    cpu_utilization = 80
  }
}
