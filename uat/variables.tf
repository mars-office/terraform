variable "env" {
  type = string
  default = "uat"
}

variable "ociTenancyOcid" {
  type = string
  sensitive = true
}

variable "ociCompartmentOcid" {
  type = string
  sensitive = true
}

variable "ociUserOcid" {
  type = string
  sensitive = true
}

variable "ociPrivateKey" {
  type = string
  sensitive = true
}

variable "ociFingerprint" {
  type = string
  sensitive = true
}

variable "ociRegion" {
  type = string
  sensitive = true
}

variable "sshKeyPrivate" {
  type = string
  sensitive = true
}

variable "sshKeyPublic" {
  type = string
  sensitive = true
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

variable "cloudflareToken" {
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
