resource "helm_release" "trivy-operator" {
  name       = "trivy-operator"
  repository = "https://aquasecurity.github.io/helm-charts/"
  chart      = "trivy-operator"
  version    = "0.18.4"
  create_namespace = false
  namespace = "trivy-system"
  timeout = 1500
  wait = true

  values = [<<EOF
trivy:
  additionalVulnerabilityReportFields: "Description,CVSS,Target,Class"
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
  scanJobsConcurrentLimit: 5
  clusterComplianceEnabled: false
  configAuditScannerEnabled: false
  exposedSecretScannerEnabled: false
  rbacAssessmentScannerEnabled: false
  sbomGenerationEnabled: false
  infraAssessmentScannerEnabled: false
  webhookBroadcastTimeout: 60s
  webhookBroadcastURL: "${var.trivy.webhookUrl}"
trivyOperator:
  additionalReportLabels: "env=${var.env},cluster=${var.clusterDns}"
  skipInitContainers: true
EOF
  ]

  count = var.trivy.enabled ? 1 : 0

  depends_on = [ helm_release.linkerd-control-plane[0], helm_release.newrelic[0] ]
}
