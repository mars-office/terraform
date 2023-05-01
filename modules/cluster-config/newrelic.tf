resource "helm_release" "newrelic" {
  name       = "newrelic"
  repository = "https://helm-charts.newrelic.com"
  chart      = "nri-bundle"
  version    = "5.0.11"
  create_namespace = true
  namespace = "newrelic"
  timeout = 500
  wait = true

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
  ksm:
    config:
      selector: "app.kubernetes.io/name=kube-state-metrics"
kube-state-metrics:
  enabled: false
newrelic-prometheus-agent:
  enabled: false
EOF
  ]

  count = var.newRelic.enabled ? 1 : 0

  depends_on = [
    helm_release.jaeger[0]
  ]
}