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
    enabled = true
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
    enabled = true
  }
  kubeapps = {
    enabled = false
  }
  gatekeeper = {
    enabled = true
  }
  vdi = {
    enabled = false
    githubToken = var.ghToken
    version = "0.0.36"
    vdis = [
      {
        name = "test"
        password = var.testVdiPassword
        persistence = {
          workspace = {
            size = "1Gi"
          }
        }
      }
    ]
  }
}
