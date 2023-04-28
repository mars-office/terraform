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
  sshKeyPrivate = var.sshKeyPrivate
  sshKeyPublic = var.sshKeyPublic
  env = var.env
  vms = [
    {
      name = "k3smaster1"
      shape = "VM.Standard.A1.Flex"
      ram = 24
      cpus = 4
      ssdSize = 200
      osImageId = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa4vff5misacsoq2khjgx5qtqtar6gcga2evkqiioorgllxvgksroq" // Canonical Ubuntu 22.04 minimal aarch64
      availabilityDomain = "UoPG:EU-FRANKFURT-1-AD-3"
      faultDomain = "FAULT-DOMAIN-1"
      master = true
      primary = true
    }
  ]
}
