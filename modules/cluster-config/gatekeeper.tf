resource "helm_release" "gatekeeper" {
  name             = "gatekeeper"
  repository       = "https://open-policy-agent.github.io/gatekeeper/charts"
  chart            = "gatekeeper"
  version          = "3.13.0-beta.0"
  create_namespace = true
  namespace        = "gatekeeper"
  timeout          = 1500
  wait = true

  values = [<<EOF

EOF
  ]

  depends_on = [
    helm_release.letsencrypt-cluster-issuer[0]
  ]

  count = var.gatekeeper.enabled ? 1 : 0
}
