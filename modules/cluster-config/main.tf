terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }
  }
}

provider "kubernetes" {
  host                   = local.host
  cluster_ca_certificate = local.ca_cert
  client_certificate     = local.client_cert
  client_key             = local.client_key
}

provider "helm" {
  kubernetes {
    host                   = local.host
    cluster_ca_certificate = local.ca_cert
    client_certificate     = local.client_cert
    client_key             = local.client_key
  }
}
