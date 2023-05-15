resource "helm_release" "kyverno" {
  name             = "kyverno"
  repository       = "https://kyverno.github.io/kyverno/"
  chart            = "kyverno"
  version          = "3.0.0-beta.1"
  create_namespace = true
  namespace        = "kyverno"
  timeout          = 1500
  wait = true

  values = [<<EOF

EOF
  ]

  depends_on = [
    helm_release.letsencrypt-cluster-issuer[0]
  ]

  count = var.kyverno.enabled ? 1 : 0
}
