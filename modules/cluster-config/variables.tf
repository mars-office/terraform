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

variable "kubernetesDashboard" {
  type = object({
    enabled = bool
    adminPassword = string
  })
}