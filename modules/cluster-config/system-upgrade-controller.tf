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

resource "helm_release" "update-plans" {
  name       = "update-plans"
  chart      = "${path.module}/charts/update-plans"
  create_namespace = false
  namespace = "system-upgrade"
  timeout = 1500
  wait = true
 values = [<<EOF
k3s:
  enabled: '${var.system-upgrade-controller.k3s.enabled}'
  version: '${var.system-upgrade-controller.k3s.version}'
EOF
  ]



  count = var.system-upgrade-controller.enabled ? 1 : 0

  depends_on = [
    helm_release.system-upgrade-controller[0]
  ]
}