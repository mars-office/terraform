resource "helm_release" "system-upgrade-controller" {
  name       = "system-upgrade-controller"
  repository = "https://nimbolus.github.io/helm-charts"
  chart      = "system-upgrade-controller"
  version    = "0.3.1"
  create_namespace = true
  namespace = "system-upgrade"
  timeout = 1500
  wait = true

  values = [<<EOF

EOF
  ]

  count = var.system-upgrade-controller.enabled ? 1 : 0
}