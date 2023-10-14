resource "helm_release" "falco-basic-auth-secret" {
  name             = "falco-basic-auth-secret"
  repository       = "https://helm.sikalabs.io"
  chart            = "basic-auth-secret"
  version          = "1.0.0"
  create_namespace = true
  namespace        = "falco"
  timeout          = 500
  wait = true
  values = [<<EOF
user: 'admin'
password: '${var.falco.adminPassword}'
EOF
  ]

  count = var.falco.enabled ? 1 : 0


  depends_on = [
    helm_release.linkerd-control-plane[0]
  ]
}

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
podAnnotations:
  linkerd.io/inject: enabled
resources:
  requests:
    cpu: 1m
    memory: 1Mi
falcosidekick:
  enabled: true
  podAnnotations:
    linkerd.io/inject: enabled
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
    disableauth: true
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

  depends_on = [ helm_release.falco-basic-auth-secret[0]]
}