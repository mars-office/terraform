terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.36.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.0"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.3.3"
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