resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.11.1"
  create_namespace = true
  namespace = "cert-manager"
  timeout = 1500
  wait = true
  values = [<<EOF
installCRDs: true
EOF
  ]

  count = var.certManager.enabled ? 1 : 0

  depends_on = [
    helm_release.ingress-nginx
  ]
}

resource "helm_release" "letsencrypt-cluster-issuer" {
  name       = "cert-manager-issuers"
  repository = "https://charts.adfinis.com"
  chart      = "cert-manager-issuers"
  version    = "0.2.5"
  create_namespace = false
  namespace = "cert-manager"
  timeout = 1500
  wait = true
  values = [<<EOF
clusterIssuers:
  - name: letsencrypt-prod
    spec:
      acme:
        email: ${var.certManager.letsEncryptEmail}
        server: https://acme-v02.api.letsencrypt.org/directory
        privateKeySecretRef:
          name: letsencrypt-prod-account-key
        solvers:
          - http01:
              ingress:
                class: nginx
  - name: letsencrypt-staging
    spec:
      acme:
        email: ${var.certManager.letsEncryptEmail}
        server: https://acme-staging-v02.api.letsencrypt.org/directory
        privateKeySecretRef:
          name: letsencrypt-staging-account-key
        solvers:
          - http01:
              ingress:
                class: nginx
  - name: self-signed
    spec:
      selfSigned: {}
EOF
  ]

  count = var.certManager.enabled ? 1 : 0

  depends_on = [
    helm_release.cert-manager[0]
  ]
}

resource "kubernetes_manifest" "root-selfsigned-ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "root-selfsigned-ca"
      "namespace" = "cert-manager"
    }
    "spec" = {
      "isCA" = true
      "commonName" = "root-selfsigned-ca"
      "secretName" = "root-selfsigned-ca"
      "privateKey" = {
        "algorithm" = "ECDSA"
        "size" = 256
      }
      "issuerRef" = {
        "name" = "self-signed"
        "kind" = "ClusterIssuer"
        "group" = "cert-manager.io"
      }
    }
  }

  count = var.certManager.enabled ? 1 : 0

  depends_on = [
    helm_release.letsencrypt-cluster-issuer[0]
  ]
}

resource "helm_release" "selfsigned-cluster-issuer" {
  name       = "cert-manager-selfsigned-issuer"
  repository = "https://charts.adfinis.com"
  chart      = "cert-manager-issuers"
  version    = "0.2.5"
  create_namespace = false
  namespace = "cert-manager"
  timeout = 1500
  wait = true
  values = [<<EOF
clusterIssuers:
  - name: selfsigned
    spec:
      ca:
        secretName: root-selfsigned-ca
EOF
  ]

  count = var.certManager.enabled ? 1 : 0

  depends_on = [
    kubernetes_manifest.root-selfsigned-ca[0]
  ]
}