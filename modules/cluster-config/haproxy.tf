resource "helm_release" "haproxy" {
  name       = "haproxy"
  repository = "https://haproxy-ingress.github.io/charts"
  chart      = "haproxy-ingress"
  version    = "0.14.5"
  create_namespace = true
  namespace = "haproxy"
  timeout = 1500
  wait = true

  values = [<<EOF
controller:
  replicaCount: 1
  hostNetwork: true
  ingressClassResource:
    enabled: true
EOF
  ]

  count = var.haproxy.enabled ? 1 : 0
}