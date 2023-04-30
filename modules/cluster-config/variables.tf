variable "kubeconfig" {
  type = string
  sensitive = true
}

variable "env" {
  type = string
}

variable "clusterDns" {
  type = string
}

variable "ghToken" {
  type = string
  sensitive = true
}

variable "nodeCount" {
  type = number
}

variable "newRelic" {
  type = object({
    enabled = bool
    ingestionKey = string
  })
  default = {
    enabled = true
    ingestionKey = null
  }
}

variable "prometheus" {
  type = object({
    enabled = bool
    adminPassword = string
  })
}

variable "certManager" {
  type = object({
    enabled = bool
    letsEncryptEmail = string
  })
}

variable "ingress" {
  type = object({
    enabled = bool
  })
}

variable "jaeger" {
  type = object({
    enabled = bool
    adminPassword = string
  })
}

variable "linkerd" {
  type = object({
    enabled = bool
    viz = bool
    jaeger = bool
    adminPassword = string
    runProxyAsRoot = bool
  })
}

variable "kubernetesDashboard" {
  type = object({
    enabled = bool
    adminPassword = string
  })
}