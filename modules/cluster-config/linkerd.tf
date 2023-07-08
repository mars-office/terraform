resource "tls_private_key" "trustanchor_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
  count       = var.linkerd.enabled ? 1 : 0


  depends_on = [
    helm_release.jaeger[0]
  ]
}

resource "tls_self_signed_cert" "trustanchor_cert" {
  private_key_pem       = tls_private_key.trustanchor_key[0].private_key_pem
  validity_period_hours = 87600
  is_ca_certificate     = true

  subject {
    common_name = "identity.linkerd.cluster.local"
  }

  allowed_uses = [
    "crl_signing",
    "cert_signing",
    "server_auth",
    "client_auth"
  ]
  count = var.linkerd.enabled ? 1 : 0


  depends_on = [
    helm_release.jaeger[0]
  ]
}

resource "tls_private_key" "issuer_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
  count       = var.linkerd.enabled ? 1 : 0

  depends_on = [
    helm_release.jaeger[0]
  ]
}

resource "tls_cert_request" "issuer_req" {
  private_key_pem = tls_private_key.issuer_key[0].private_key_pem

  subject {
    common_name = "identity.linkerd.cluster.local"
  }
  count = var.linkerd.enabled ? 1 : 0


  depends_on = [
    helm_release.jaeger[0]
  ]
}

resource "tls_locally_signed_cert" "issuer_cert" {
  cert_request_pem      = tls_cert_request.issuer_req[0].cert_request_pem
  ca_private_key_pem    = tls_private_key.trustanchor_key[0].private_key_pem
  ca_cert_pem           = tls_self_signed_cert.trustanchor_cert[0].cert_pem
  validity_period_hours = 8760
  is_ca_certificate     = true

  allowed_uses = [
    "crl_signing",
    "cert_signing",
    "server_auth",
    "client_auth"
  ]
  count = var.linkerd.enabled ? 1 : 0


  depends_on = [
    helm_release.jaeger[0]
  ]
}

resource "helm_release" "linkerd-crds" {
  name             = "linkerd-crds"
  repository       = "https://helm.linkerd.io/stable"
  chart            = "linkerd-crds"
  version          = "1.6.1"
  create_namespace = true
  namespace        = "linkerd"
  timeout          = 500
  wait = true
  values = [<<EOF

EOF
  ]

  count = var.linkerd.enabled ? 1 : 0


  depends_on = [
    helm_release.jaeger[0]
  ]
}

resource "helm_release" "linkerd-control-plane" {
  name             = "linkerd-control-plane"
  repository       = "https://helm.linkerd.io/stable"
  chart            = "linkerd-control-plane"
  version          = "1.12.2"
  create_namespace = false
  namespace        = "linkerd"
  timeout          = 500
  wait = true
  set {
    name  = "identityTrustAnchorsPEM"
    value = tls_self_signed_cert.trustanchor_cert[0].cert_pem
  }

  set {
    name  = "identity.issuer.tls.crtPEM"
    value = tls_locally_signed_cert.issuer_cert[0].cert_pem
  }

  set {
    name  = "identity.issuer.tls.keyPEM"
    value = tls_private_key.issuer_key[0].private_key_pem
  }

  set {
    name  = "proxyInit.runAsRoot"
    value = var.linkerd.runProxyAsRoot
  }


  values = [<<EOF
proxyInit:
  resources:
    cpu:
      request: 1m
    memory:
      request: 1Mi
EOF
  ]

  count = var.linkerd.enabled ? 1 : 0


  depends_on = [
    helm_release.linkerd-crds[0]
  ]
}


resource "helm_release" "linkerd-basic-auth-secret" {
  name             = "linkerd-basic-auth-secret"
  repository       = "https://helm.sikalabs.io"
  chart            = "basic-auth-secret"
  version          = "1.0.0"
  create_namespace = true
  namespace        = "linkerd-viz"
  timeout          = 500
  wait = true
  values = [<<EOF
user: 'admin'
password: '${var.linkerd.adminPassword}'
EOF
  ]

  count = var.linkerd.enabled && var.linkerd.viz ? 1 : 0


  depends_on = [
    helm_release.linkerd-control-plane[0]
  ]
}

resource "helm_release" "linkerd-viz" {
  name             = "linkerd-viz"
  repository       = "https://helm.linkerd.io/stable"
  chart            = "linkerd-viz"
  version          = "30.8.2"
  create_namespace = false
  namespace        = "linkerd-viz"
  timeout          = 500
  wait = true
  set {
    name  = "prometheus.enabled"
    value = var.prometheus.enabled ? "false" : "true"
  }

  set {
    name  = "prometheusUrl"
    value = var.prometheus.enabled ? "http://prometheus-server.prometheus:80" : ""
  }

  set {
    name  = "jaegerUrl"
    value = var.jaeger.enabled && var.linkerd.jaeger ? "https://jaeger.${var.clusterDns}" : ""
  }

  values = [<<EOF

EOF
  ]

  count = var.linkerd.enabled && var.linkerd.viz ? 1 : 0


  depends_on = [
    helm_release.linkerd-basic-auth-secret[0]
  ]
}

resource "kubernetes_ingress_v1" "linkerd-viz-ingress" {
  metadata {
    namespace = "linkerd-viz"
    name = "linkerd-viz"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/configuration-snippet" = <<EOF
proxy_set_header Origin "";
proxy_hide_header l5d-remote-ip;
proxy_hide_header l5d-server-id; 
EOF
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/upstream-vhost" = "$service_name.$namespace.svc.cluster.local:8084"
      "nginx.ingress.kubernetes.io/auth-type" = "basic"
      "nginx.ingress.kubernetes.io/auth-secret" = "linkerd-basic-auth-secret"
      "nginx.ingress.kubernetes.io/auth-realm" = "Authentication Required Bro"
    }
  }

  spec {
    rule {
      host = "linkerd.${var.clusterDns}"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "web"
              port {
                number = 8084
              }
            }
          }
        }
      }
    }
    tls {
      hosts = ["linkerd.${var.clusterDns}"]
      secret_name = "linkerd-ingress-tls"
    }
  }

  count = var.linkerd.enabled && var.linkerd.viz ? 1 : 0

  depends_on = [
    helm_release.linkerd-viz[0]
  ]
}

locals {
  newRelicOtlpConfig = <<EOF
      otlp:
        endpoint: https://otlp.eu01.nr-data.net
        headers:
          api-key: ${var.newRelic.ingestionKey}
EOF
}

resource "helm_release" "linkerd-jaeger" {
  name             = "linkerd-jaeger"
  repository       = "https://helm.linkerd.io/stable"
  chart            = "linkerd-jaeger"
  version          = "30.8.2"
  create_namespace = true
  namespace        = "linkerd-jaeger"
  timeout          = 500
  wait = true

  values = [
<<EOF
jaeger:
  enabled: ${var.jaeger.enabled ? "false" : "true"}

collector:
  config: |
    receivers:
      otlp:
        protocols:
          grpc:
          http:
      opencensus:
      zipkin:
      jaeger:
        protocols:
          grpc:
          thrift_http:
          thrift_compact:
          thrift_binary:
    processors:
      batch:
    extensions:
      health_check:
    exporters:
${var.newRelic.enabled ? local.newRelicOtlpConfig : ""}
      jaeger:
        endpoint: ${var.jaeger.enabled ? "jaeger-collector.jaeger:14250" : "collector.linkerd-jaeger:14250"}
        tls:
          insecure: true
    service:
      extensions: [health_check]
      pipelines:
        traces:
          receivers: [otlp,opencensus,zipkin,jaeger]
          processors: [batch]
          exporters: [jaeger]
EOF
  ]

  count = var.linkerd.enabled && var.linkerd.jaeger ? 1 : 0


  depends_on = [
    helm_release.linkerd-viz[0]
  ]
}