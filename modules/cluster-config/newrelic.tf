resource "helm_release" "newrelic" {
  name       = "newrelic"
  repository = "https://helm-charts.newrelic.com"
  chart      = "nri-bundle"
  version    = "5.0.11"
  create_namespace = true
  namespace = "newrelic"

  values = [<<EOF
logging:
  enabled: true
newrelic-logging:
  lowDataMode: true
global:
  licenseKey: ${var.newRelic.ingestionKey}
  cluster: ${var.env}
  lowDataMode: true
newrelic-infrastructure:
  privileged: true
kube-state-metrics:
  enabled: true
newrelic-prometheus-agent:
  enabled: true
  lowDataMode: true
  config:
    kubernetes:
      integrations_filter:
        enabled: false
EOF
  ]

  count = var.newRelic.enabled ? 1 : 0
}