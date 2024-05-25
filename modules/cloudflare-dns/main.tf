terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.33.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflareToken
}