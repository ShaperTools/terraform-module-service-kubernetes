terraform {
  required_version = ">= 0.13.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.9.4"
    }
  }
}
