resource "helm_release" "trivy-operator" {
  name       = "trivy-operator"
  repository = "https://aquasecurity.github.io/helm-charts/"
  chart      = "trivy-operator"
  version    = "0.18.3"
  create_namespace = true
  namespace = "trivy-system"
  timeout = 1500
  wait = true

  values = [<<EOF
operator:
  webhookBroadcastURL: "${var.trivy.slackWebhook}"
trivy:
  resources:
    requests:
      cpu: 1m
      memory: 1Mi
EOF
  ]

  count = var.trivy.enabled ? 1 : 0
}