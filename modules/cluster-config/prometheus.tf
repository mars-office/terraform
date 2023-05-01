resource "helm_release" "prometheus-basic-auth-secret" {
  name       = "prometheus-basic-auth-secret"
  repository = "https://helm.sikalabs.io"
  chart      = "basic-auth-secret"
  version    = "1.0.0"
  create_namespace = true
  namespace = "prometheus"
  timeout = 500
  wait = true

  values = [<<EOF
user: 'admin'
password: '${var.prometheus.adminPassword}'
EOF
  ]

  count = var.prometheus.enabled ? 1 : 0


  depends_on = [
    helm_release.letsencrypt-cluster-issuer[0]
  ]
}


resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "21.1.2"
  create_namespace = false
  namespace = "prometheus"
  timeout = 500
  wait = true

  values = [<<EOF
server:
  global:
    scrape_interval: 15m
    evaluation_interval: 15m
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/service-upstream: "true"
      cert-manager.io/cluster-issuer: letsencrypt-prod
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: prometheus-basic-auth-secret
      nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required Bro'
    hosts:
      - prometheus.${var.clusterDns}
    tls:
      - secretName: prometheus-ingress-tls
        hosts:
          - prometheus.${var.clusterDns}
alertmanager:
  enabled: false
kube-state-metrics:
  enabled: ${var.newRelic.enabled ? "false" : "true"}
EOF
  ]

  count = var.prometheus.enabled ? 1 : 0

  depends_on = [
    helm_release.prometheus-basic-auth-secret[0]
  ]
}
