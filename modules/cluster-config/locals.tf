locals {
  kubeconfigObj = yamldecode(var.kubeconfig)
  host        = local.kubeconfigObj.clusters[0].cluster.server
  ca_cert     = base64decode(local.kubeconfigObj.clusters[0].cluster.certificate-authority-data)
  client_cert = base64decode(local.kubeconfigObj.users[0].user.client-certificate-data)
  client_key  = base64decode(local.kubeconfigObj.users[0].user.client-key-data)
}
