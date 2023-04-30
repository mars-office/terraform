resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.6.0"
  create_namespace = true
  namespace = "ingress-nginx"
  timeout = 500

  values = [<<EOF
controller:
  replicaCount: ${var.nodeCount}
  resources:
    requests:
      cpu: 1m
      memory: 1Mi
EOF
  ]

  count = var.ingress.enabled ? 1 : 0
}