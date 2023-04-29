resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "21.1.1"
  create_namespace = true
  namespace = "prometheus"

  values = [<<EOF
global:
  scrape_interval: 10m
  evaluation_interval: 10m
alertmanager:
  enabled: false
kube-state-metrics:
  enabled: ${var.newRelic.enabled ? "false" : "true"}
EOF
  ]

  count = var.prometheus.enabled ? 1 : 0
}