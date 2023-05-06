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
nri-kube-events:
  enabled: true
newrelic-logging:
  lowDataMode: true
  resources:
    limits:
      cpu: 500m
      memory: 128Mi
    requests:
      cpu: 1m
      memory: 1Mi
global:
  licenseKey: ${var.newRelic.ingestionKey}
  cluster: ${var.env}
  lowDataMode: true
newrelic-infrastructure:
  common:
    config:
      interval: 60s
  privileged: true
  controlPlane:
    resources:
      limits:
        memory: 300M
      requests:
        cpu: 1m
        memory: 1Mi
  kubelet:
    resources:
      limits:
        memory: 300M
      requests:
        cpu: 1m
        memory: 1Mi
  ksm:
    resources:
      limits:
        memory: 850M  # Bump me up if KSM pod shows restarts.
      requests:
        cpu: 1m
        memory: 1Mi
    config:
      selector: "app.kubernetes.io/name=kube-state-metrics"
kube-state-metrics:
  enabled: false
newrelic-prometheus-agent:
  enabled: false
nri-metadata-injection:
  resources:
    limits:
      memory: 80M
    requests:
      cpu: 1m
      memory: 1Mi
EOF
  ]

  count = var.newRelic.enabled ? 1 : 0

  depends_on = [
    helm_release.jaeger[0]
  ]
}