variable "kubeconfig" {
  type = string
  sensitive = true
}

variable "env" {
  type = string
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