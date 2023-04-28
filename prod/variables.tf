variable "env" {
  type = string
  default = "prod"
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
