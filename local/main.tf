terraform {
  backend "local" {
  }
}

module "cluster-config" {
  source = "../modules/cluster-config"
  kubeconfig = file("~/.kube/config")
  env = var.env
  appNamespaces = ["huna"]
  github = {
    username = var.ghUsername
    email = var.ghEmail
    token = var.ghToken
  }
  clusterDns = "marsconceptor.local"
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
    enabled = false
    adminPassword = var.jaegerPassword
  }
  linkerd = {
    adminPassword = var.linkerdPassword
    enabled = true
    jaeger = false
    viz = false
    runProxyAsRoot = true
  }
  kubernetesDashboard = {
    adminPassword = var.kubernetesDashboardPassword
    enabled = false
  }
  kubeapps = {
    enabled = false
  }
}
