terraform {
  cloud {
    organization = "mars-office"
    workspaces {
      name = "uat"
    }
  }
}

module "oci" {
  source = "../modules/oci"
  ociTenancyOcid = var.ociTenancyOcid
  ociUserOcid = var.ociUserOcid
  ociPrivateKey = var.ociPrivateKey
  ociFingerprint = var.ociFingerprint
  ociRegion = var.ociRegion
  ociCompartmentOcid = var.ociCompartmentOcid
}
