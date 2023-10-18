terraform {
  backend "local" {
  }
}

module "cluster-config" {
  source = "../modules/cluster-config"
  kubeconfig = file("~/.kube/config")
  env = var.env
  github = {
    username = var.ghUsername
    email = var.ghEmail
    token = var.ghToken
  }
  clusterDns = "local.marsconceptor.com"
  nodeCount = 1
  newRelic = {
    enabled = false
    ingestionKey = var.newRelicIngestionLicenseKey
  }
  prometheus = {
    enabled = false
    adminPassword = var.prometheusPassword
    remoteWrite = false
  }
  ingress = {
    enabled = true
  }
  certManager = {
    enabled = true
    letsEncryptEmail = var.letsEncryptEmail
    issuer = "root-ca"
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
  gatekeeper = {
    enabled = true
  }
  keda = {
    enabled = false
  }
  telepresence = {
    enabled = true
  }
  trivy = {
    enabled = true
    slackWebhook = var.trivySlackWebhook
  }
}
