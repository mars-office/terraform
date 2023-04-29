terraform {
  backend "local" {
  }
}

module "cluster-config" {
  source = "../modules/cluster-config"
  kubeconfig = file("~/.kube/config")
  env = var.env
  newRelic = {
    enabled = false
    ingestionKey = var.newRelicIngestionLicenseKey
  }
  prometheus = {
    enabled = false
  }
}
