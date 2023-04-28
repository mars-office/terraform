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

variable "env" {
  type = string
}

variable "sshKeyPrivate" {
  type = string
  sensitive = true
}

variable "sshKeyPublic" {
  type = string
  sensitive = true
}

variable "vms" {
  type = list(object({
    name = string
    master = bool
    primary = bool
    shape = string
    availabilityDomain = string
    faultDomain = string
    ram = number
    ssdSize = number
    cpus = number
    osImageId = string
  }))
}