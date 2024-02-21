resource "helm_release" "keda" {
  name       = "keda"
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  version    = "2.12.1"
  create_namespace = true
  namespace = "keda"
  timeout = 1500
  wait = true

  values = [<<EOF

EOF
  ]

  count = var.keda.enabled ? 1 : 0
}