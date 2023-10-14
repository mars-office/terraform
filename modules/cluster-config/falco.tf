resource "helm_release" "falco" {
  name       = "falco"
  repository = "https://falcosecurity.github.io/charts"
  chart      = "falco"
  version    = "3.7.1"
  create_namespace = true
  namespace = "falco"
  timeout = 1500
  wait = true

  values = [<<EOF
tty: false
resources:
  requests:
    cpu: 1m
    memory: 1Mi
EOF
  ]

  count = var.falco.enabled ? 1 : 0

  depends_on = [ helm_release.linkerd-control-plane[0]]
}

resource "helm_release" "falcosidekick" {
  name       = "falcosidekick"
  repository = "https://falcosecurity.github.io/charts"
  chart      = "falcosidekick"
  version    = "0.7.2"
  create_namespace = true
  namespace = "falco"
  timeout = 1500
  wait = true

  values = [<<EOF
replicaCount: 1
webui:
  enabled: true
  podAnnotations:
    linkerd.io/inject: enabled
  redis:
    podAnnotations:
      linkerd.io/inject: enabled
  replicaCount: 1
  loglevel: info
  disableauth: false
  user: admin:${var.falco.adminPassword}
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      cert-manager.io/cluster-issuer: ${var.certManager.issuer}
    hosts:
      - host: falco.${var.clusterDns}
        paths:
          - path: /
    tls:
      - secretName: falco-ingress-tls
        hosts:
          - falco.${var.clusterDns}
EOF
  ]

  count = var.falco.enabled ? 1 : 0

  depends_on = [ helm_release.falco[0]]
}