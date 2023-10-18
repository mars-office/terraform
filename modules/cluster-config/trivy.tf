resource "helm_release" "postee" {
  name       = "postee"
  repository = "https://aquasecurity.github.io/helm-charts/"
  chart      = "postee"
  version    = "2.14.0"
  create_namespace = true
  namespace = "postee"
  timeout = 1500
  wait = true

  values = [<<EOF
uiService:
  type: ClusterIP
persistentVolume:
  enabled: false
resources:
  requests:
    cpu: 1m
    memory: 1Mi
posteUi:
  user: admin
  pass: ${var.trivy.posteePassword}
EOF
  ]

  count = var.trivy.enabled ? 1 : 0
}

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