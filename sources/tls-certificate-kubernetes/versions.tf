terraform {
  required_version = ">= 0.13.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.13.2"
    }
    acme = {
      source  = "terraform-providers/acme"
      version = ">= 1.5.0"
    }
  }
}
