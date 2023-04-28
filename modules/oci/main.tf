terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "4.118.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.4.3"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.2.0"
    }
  }
}

provider "oci" {
  tenancy_ocid = var.ociTenancyOcid
  user_ocid = var.ociUserOcid
  private_key = var.ociPrivateKey
  fingerprint = var.ociFingerprint
  region = var.ociRegion
}