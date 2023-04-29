variable "env" {
  type = string
  default = "local"
}

variable "newRelicIngestionLicenseKey" {
  type = string
  sensitive = true
}