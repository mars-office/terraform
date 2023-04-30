terraform {
  cloud {
    organization = "mars-office"
    workspaces {
      name = "prod"
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
  clusterDns = "${var.env}.marsoffice.com"
  vms = [
    {
      name = "k3smaster1"
      shape = "VM.Standard.A1.Flex"
      ram = 24
      cpus = 4
      ssdSize = 200
      osImageId = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa4vff5misacsoq2khjgx5qtqtar6gcga2evkqiioorgllxvgksroq" // Canonical Ubuntu 22.04 minimal aarch64
      availabilityDomain = "UoPG:EU-FRANKFURT-1-AD-1"
      faultDomain = null
      master = true
      primary = true
    }
  ]
}


module "ssh-extract-kubeconfig" {
  source = "../modules/ssh-extract-kubeconfig"
  sshKeyPrivate = var.sshKeyPrivate
  ip = [for vm in module.oci.vms : vm.public_ip if vm.primary == true][0]
}

module "kubeconfig-github-secret" {
  source = "../modules/kubeconfig-github-secret"
  ghToken = var.ghToken
  kubeconfig = module.ssh-extract-kubeconfig.kubeconfig
  env = var.env
}

module "cloudflare-dns-cluster" {
  source = "../modules/cloudflare-dns"
  cloudflareToken = var.cloudflareToken
  zoneName = "marsconceptor.com"
  records = [for vm in module.oci.vms : {
    name = var.env
    type = "A"
    value = vm.public_ip
  } if vm.master == true]
}

module "cloudflare-dns-clusterapps" {
  source = "../modules/cloudflare-dns"
  cloudflareToken = var.cloudflareToken
  zoneName = "marsconceptor.com"
  records = concat(
    [for vm in module.oci.vms : {
      name = "dashboard.${var.env}"
      type = "A"
      value = vm.public_ip
    }],
    [for vm in module.oci.vms : {
      name = "kubeapps.${var.env}"
      type = "A"
      value = vm.public_ip
    }],
  )
}

module "cluster-config" {
  source = "../modules/cluster-config"
  kubeconfig = module.ssh-extract-kubeconfig.kubeconfig
  nodeCount = length(module.oci.vms)
  env = var.env
  clusterDns = "${var.env}.marsoffice.com"
  newRelic = {
    enabled = true
    ingestionKey = var.newRelicIngestionLicenseKey
  }
  prometheus = {
    enabled = true
  }
  ingress = {
    enabled = true
  }
}


// APPS DNS
module "cloudflare-dns-huna" {
  source = "../modules/cloudflare-dns"
  cloudflareToken = var.cloudflareToken
  zoneName = "huna2.com"
  records = concat([for vm in module.oci.vms : {
    name = "@"
    type = "A"
    value = vm.public_ip
  }],
  [
    {
      name = "www.${var.env}"
      type = "CNAME"
      value = "huna2.com"
    }
  ])
}