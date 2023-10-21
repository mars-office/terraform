resource "helm_release" "postee" {
  name       = "postee"
  repository = "https://aquasecurity.github.io/helm-charts/"
  chart      = "postee"
  version    = "2.14.0"
  create_namespace = true
  namespace = "trivy-system"
  timeout = 1500
  wait = true

  values = [<<EOF
posteeConfig: |
  routes:
  - name: Trivy Operator Alerts
    input: input.report.summary.highCount > 0
    actions: [send-slack-msg]
    template: trivy-operator-slack
  
  templates:
  - name: trivy-operator-slack
    rego-package: postee.trivyoperator.slack

  actions:
  - name: send-slack-msg
    type: slack
    enable: true
    url: "${var.trivy.trivyWebhookUrl}"

posteUi:
  user: "admin"
  pass: "${var.trivy.posteeUiPassword}"
  image: ghcr.io/mars-office/posteeui
  tag: latest

image:
  repository: ghcr.io/mars-office/postee
  tag: latest

uiService:
  type: ClusterIP

resources:
  requests:
    cpu: 1m
    memory: 1Mi

persistentVolume:
  enabled: false

EOF
  ]

  count = var.trivy.enabled ? 1 : 0

  depends_on = [ helm_release.linkerd-control-plane[0] ]
}

resource "helm_release" "trivy-operator" {
  name       = "trivy-operator"
  repository = "https://aquasecurity.github.io/helm-charts/"
  chart      = "trivy-operator"
  version    = "0.18.3"
  create_namespace = false
  namespace = "trivy-system"
  timeout = 1500
  wait = true

  values = [<<EOF
trivy:
  server:
    resources:
      requests:
        cpu: 1m
        memory: 1Mi
  resources:
    requests:
      cpu: 1m
      memory: 1Mi
operator:
  webhookBroadcastURL: "http://postee.trivy-system:8082"
  scanJobsConcurrentLimit: 5
trivyOperator:
  additionalReportLabels: "env=${var.env},cluster=${var.clusterDns}"
EOF
  ]

  count = var.trivy.enabled ? 1 : 0

  depends_on = [ helm_release.postee[0] ]
}
