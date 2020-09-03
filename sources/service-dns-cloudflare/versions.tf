terraform {
  required_version = ">= 0.13.0"

  required_providers {
    cloudflare = {
      source  = "terraform-providers/cloudflare"
      version = ">= 2.10.0"
    }
  }
}
