terraform {
  cloud {
    organization = "mars-office"
  }
}

module "oci" {
  source = "../modules/oci"
  ociTenancyOcid = var.ociTenancyOcid
  ociUserOcid = var.ociUserOcid
  ociPrivateKey = var.ociPrivateKey
  ociFingerprint = var.ociFingerprint
  ociRegion = var.ociRegion
}
