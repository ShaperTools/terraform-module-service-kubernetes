data "terraform_remote_state" "previous_state" {
  count = var.new ? 0 : 1

  backend = "s3"

  config = {
    bucket               = var.current_stack_state_configuration.bucket
    key                  = var.current_stack_state_configuration.key
    region               = var.current_stack_state_configuration.region
    workspace_key_prefix = var.current_stack_state_configuration.workspace_key_prefix
    acl                  = "private"
    encrypt              = true
  }
}

locals {
  active_environment_previous   = lookup(var.new ? {} : data.terraform_remote_state.previous_state[0].outputs[var.service_state_output_name], "active_environment", "blue")
  docker_image_active_previous  = lookup(var.new ? {} : data.terraform_remote_state.previous_state[0].outputs[var.service_state_output_name], "docker_image_active", "-")
  docker_image_passive_previous = lookup(var.new ? {} : data.terraform_remote_state.previous_state[0].outputs[var.service_state_output_name], "docker_image_passive", "-")

  active_environment = var.active_environment == "" ? local.active_environment_previous : var.active_environment
  swap_environments  = local.active_environment != local.active_environment_previous

  docker_image_active_calculated  = local.swap_environments == true ? local.docker_image_passive_previous : local.docker_image_active_previous
  docker_image_passive_calculated = local.swap_environments == true ? local.docker_image_active_previous : local.docker_image_passive_previous

  docker_image_active  = var.docker_image_active == "" ? local.docker_image_active_calculated : var.docker_image_active
  docker_image_passive = var.docker_image_passive == "" ? local.docker_image_passive_calculated : var.docker_image_passive

  ingresses_passive_intermediate = [for x in var.ingresses : {
    annotations = x.annotations
    rules = [for y in x.rules : {
      host_pieces                 = split(".", y.host),
      host                        = y.host,
      path                        = y.path,
      tls_certificate_secret_name = y.tls_certificate_secret_name
    }]
  }]

  ingresses_passive = [for x in local.ingresses_passive_intermediate : {
    annotations = x.annotations
    rules = [for y in x.rules : {
      host                        = join(".", concat(["${y.host_pieces[0]}-passive"], length(y.host_pieces) > 1 ? slice(y.host_pieces, 1, length(y.host_pieces)) : []))
      path                        = y.path,
      tls_certificate_secret_name = y.tls_certificate_secret_name
    }]
  }]
}

module "service-blue" {
  source = "../service-environment-kubernetes"

  disabled = local.active_environment == "blue" ? local.docker_image_active == "-" : local.docker_image_passive == "-"

  args                     = var.args
  desired_count            = var.desired_count
  docker_image             = local.active_environment == "blue" ? local.docker_image_active : local.docker_image_passive
  environment_variables    = var.environment_variables
  secret_envs              = var.secret_envs
  image_pull_secret_name   = var.image_pull_secret_name
  ingresses                = local.active_environment == "blue" ? var.ingresses : local.ingresses_passive
  max_surge                = var.max_surge
  max_unavailable          = var.max_unavailable
  namespace                = var.namespace
  port                     = var.port
  resource_requests        = var.resource_requests
  resource_limits          = var.resource_limits
  service_environment_name = "${var.service_name}-blue"
  volume_mounts            = var.volume_mounts
  volumes                  = var.volumes
  node_selector            = var.node_selector
  mergeable_ingress        = var.mergeable_ingress
}

module "service-green" {
  source = "../service-environment-kubernetes"

  disabled = local.active_environment == "green" ? local.docker_image_active == "-" : local.docker_image_passive == "-"

  args                     = var.args
  desired_count            = var.desired_count
  docker_image             = local.active_environment == "green" ? local.docker_image_active : local.docker_image_passive
  environment_variables    = var.environment_variables
  secret_envs              = var.secret_envs
  image_pull_secret_name   = var.image_pull_secret_name
  ingresses                = local.active_environment == "green" ? var.ingresses : local.ingresses_passive
  max_surge                = var.max_surge
  max_unavailable          = var.max_unavailable
  namespace                = var.namespace
  port                     = var.port
  resource_requests        = var.resource_requests
  resource_limits          = var.resource_limits
  service_environment_name = "${var.service_name}-green"
  volume_mounts            = var.volume_mounts
  volumes                  = var.volumes
  node_selector            = var.node_selector
  mergeable_ingress        = var.mergeable_ingress
}
