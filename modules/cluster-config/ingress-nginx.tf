resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.8.3"
  create_namespace = true
  namespace = "ingress-nginx"
  timeout = 1500
  wait = true

  values = [<<EOF
controller:
  allowSnippetAnnotations: true
  replicaCount: ${var.nodeCount}
  resources:
    requests:
      cpu: 1m
      memory: 1Mi
EOF
  ]

  set {
    name  = "controller.config.enable-opentracing"
    value = var.linkerd.enabled && var.linkerd.jaeger ? "true" : "false"
    type = "string"
  }

  set {
    name  = "controller.config.zipkin-collector-host"
    value = "collector.linkerd-jaeger"
  }

  set {
    name  = "controller.podAnnotations.linkerd\\.io/inject"
    value = "enabled"
  }

  count = var.ingress.enabled ? 1 : 0

  depends_on = [ helm_release.linkerd-control-plane[0] ]
}