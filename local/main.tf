terraform {
  backend "local" {
  }
}

module "cluster-config" {
  source = "../modules/cluster-config"
  kubeconfig = file("~/.kube/config")
  env = var.env
  clusterDns = "marsoffice.127.0.0.1.nip.io"
  nodeCount = 1
  newRelic = {
    enabled = false
    ingestionKey = var.newRelicIngestionLicenseKey
  }
  prometheus = {
    enabled = true
    adminPassword = var.prometheusPassword
  }
  ingress = {
    enabled = true
  }
  certManager = {
    enabled = false
    letsEncryptEmail = var.letsEncryptEmail
  }
  jaeger = {
    enabled = true
    adminPassword = var.jaegerPassword
  }
  linkerd = {
    adminPassword = var.linkerdPassword
    enabled = true
    jaeger = true
    viz = true
    runProxyAsRoot = true
  }
  kubernetesDashboard = {
    adminPassword = var.kubernetesDashboardPassword
    enabled = true
  }
}
