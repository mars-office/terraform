resource "helm_release" "haproxy" {
  name       = "kubernetes-ingress"
  repository = "https://haproxytech.github.io/helm-charts"
  chart      = "kubernetes-ingress"
  version    = "1.35.3"
  create_namespace = true
  namespace = "haproxy"
  timeout = 1500
  wait = true

  values = [<<EOF
controller:
  replicaCount: 1
EOF
  ]

  count = var.haproxy.enabled ? 1 : 0
}