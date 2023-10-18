variable "kubeconfig" {
  type = string
  sensitive = true
}

variable "env" {
  type = string
}

variable "clusterDns" {
  type = string
}

variable "github" {
  type = object({
    token = string
    username = string
    email = string
  })
}

variable "nodeCount" {
  type = number
}

variable "newRelic" {
  type = object({
    enabled = bool
    ingestionKey = string
  })
}

variable "prometheus" {
  type = object({
    enabled = bool
    adminPassword = string
    remoteWrite = bool
  })
}

variable "kubeapps" {
  type = object({
    enabled = bool
  })
}

variable "certManager" {
  type = object({
    enabled = bool
    letsEncryptEmail = string
    issuer = string
  })
}

variable "ingress" {
  type = object({
    enabled = bool
  })
}

variable "gatekeeper" {
  type = object({
    enabled = bool
  })
}

variable "jaeger" {
  type = object({
    enabled = bool
    adminPassword = string
  })
}

variable "linkerd" {
  type = object({
    enabled = bool
    viz = bool
    jaeger = bool
    adminPassword = string
    runProxyAsRoot = bool
  })
}

variable "kubernetesDashboard" {
  type = object({
    enabled = bool
    adminPassword = string
  })
}

variable "keda" {
  type = object({
    enabled = bool
  })
}

variable "telepresence" {
  type = object({
    enabled = bool
  })
}

variable "trivy" {
  type = object({
    enabled = bool
    slackWebhook = string
    posteePassword = string
  })
}