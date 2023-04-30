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