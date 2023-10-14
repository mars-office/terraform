resource "kubernetes_namespace" "falco" {
  metadata {
    name = "falco"
  }

  count = var.falco.enabled ? 1 : 0
  depends_on = [ helm_release.linkerd-control-plane[0]]
}

resource "kubernetes_secret" "falco-ui-config" {
  metadata {
    namespace = kubernetes_namespace.falco[0].metadata[0].name
    name = "falco-ui-config"
  }

  data = {
    "FALCOSIDEKICK_UI_USER" = "admin:${var.falco.adminPassword}"
  }

  count = var.falco.enabled ? 1 : 0
}

resource "helm_release" "falco" {
  name       = "falco"
  repository = "https://falcosecurity.github.io/charts"
  chart      = "falco"
  version    = "3.7.1"
  create_namespace = false
  namespace = kubernetes_namespace.falco[0].metadata[0].name
  timeout = 1500
  wait = true

  values = [<<EOF
tty: false
resources:
  requests:
    cpu: 1m
    memory: 1Mi
falcosidekick:
  enabled: true
  replicaCount: 1
  webui:
    enabled: true
    podAnnotations:
      linkerd.io/inject: enabled
    redis:
      podAnnotations:
        linkerd.io/inject: enabled
    replicaCount: 1
    existingSecret: ${kubernetes_secret.falco-ui-config[0].metadata[0].name}
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
}

