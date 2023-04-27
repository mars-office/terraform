terraform {
  backend "local" {
  }
}

module "cluster-config" {
  source = "../modules/cluster-config"
  kubeconfig = file("~/.kube/config")
}
