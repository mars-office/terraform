resource "helm_release" "telepresence" {
  name       = "telepresence"
  repository = "https://app.getambassador.io"
  chart      = "traffic-manager"
  version    = "2.10.2"
  create_namespace = true
  namespace = "ambassador"
  timeout = 1500
  wait = true

  values = [<<EOF

EOF
  ]

  count = var.telepresence.enabled ? 1 : 0
}