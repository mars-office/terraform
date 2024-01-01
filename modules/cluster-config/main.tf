terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.0.5"
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
