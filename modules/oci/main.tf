terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.43.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.2"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.3.4"
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