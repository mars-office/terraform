variable "env" {
  type = string
  default = "dev"
}

variable "ociTenancyOcid" {
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