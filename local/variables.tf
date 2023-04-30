variable "env" {
  type = string
  default = "local"
}

variable "newRelicIngestionLicenseKey" {
  type = string
  sensitive = true
}

variable "letsEncryptEmail" {
  type = string
  sensitive = true
}

variable "kubernetesDashboardPassword" {
  type = string
  sensitive = true
}

variable "kubeappsPassword" {
  type = string
  sensitive = true
}

variable "jaegerPassword" {
  type = string
  sensitive = true
}

variable "prometheusPassword" {
  type = string
  sensitive = true
}

variable "linkerdPassword" {
  type = string
  sensitive = true
}