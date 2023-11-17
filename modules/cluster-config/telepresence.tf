resource "helm_release" "telepresence" {
  name       = "traffic-manager"
  repository = "https://app.getambassador.io"
  chart      = "telepresence"
  version    = "2.17.0"
  create_namespace = true
  namespace = "ambassador"
  timeout = 1500
  wait = true

  values = [<<EOF

EOF
  ]

  count = var.telepresence.enabled ? 1 : 0
}