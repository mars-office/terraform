resource "helm_release" "jaeger-basic-auth-secret" {
  name       = "jaeger-basic-auth-secret"
  repository = "https://helm.sikalabs.io"
  chart      = "basic-auth-secret"
  version    = "1.0.0"
  create_namespace = true
  namespace = "jaeger"
  timeout = 1500
  wait = true
  values = [<<EOF
user: 'admin'
password: '${var.jaeger.adminPassword}'
EOF
  ]

  count = var.jaeger.enabled ? 1 : 0


  depends_on = [
    helm_release.prometheus[0]
  ]
}


resource "helm_release" "jaeger" {
  name       = "jaeger"
  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger"
  version    = "2.1.0"
  create_namespace = false
  namespace = "jaeger"
  timeout = 1500
  wait = true
  values = [<<EOF
provisionDataStore:
  cassandra: false
storage:
  type: memory
agent:
  enabled: false
collector:
  enabled: false
query:
  enabled: false
allInOne:
  enabled: true
  resources:
    limits:
      cpu: 300m
      memory: 512Mi
    requests:
      cpu: 50m
      memory: 128Mi
  ingress:
    enabled: true
    pathType: Prefix
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      cert-manager.io/cluster-issuer: ${var.certManager.issuer}
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: jaeger-basic-auth-secret
      nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required Bro'
    hosts:
      - jaeger.${var.clusterDns}
    tls:
      - secretName: jaeger-ingress-tls
        hosts:
          - jaeger.${var.clusterDns}
EOF
  ]

  count = var.jaeger.enabled ? 1 : 0

  depends_on = [
    helm_release.jaeger-basic-auth-secret[0]
  ]
}
