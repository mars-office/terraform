terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "4.118.0"
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