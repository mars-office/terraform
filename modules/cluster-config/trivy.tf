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
  scanJobsConcurrentLimit: 5
trivyOperator:
  additionalReportLabels: "env=${var.env},cluster=${var.clusterDns}"
EOF
  ]

  count = var.trivy.enabled ? 1 : 0

  depends_on = [ helm_release.linkerd-control-plane[0] ]
}
