terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.16.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflareToken
}