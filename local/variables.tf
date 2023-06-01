variable "env" {
  type = string
  default = "local"
}

variable "ghToken" {
  type = string
  sensitive = true
}

variable "ghUsername" {
  type = string
  sensitive = true
}

variable "ghEmail" {
  type = string
  sensitive = true
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

variable "testVdiPassword" {
  type = string
  sensitive = true
}