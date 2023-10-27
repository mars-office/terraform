terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "5.40.0"
    }
  }
}

provider "github" {
  token = var.ghToken
  owner = local.orgName
}