resource "helm_release" "postee" {
  name       = "postee"
  repository = "https://aquasecurity.github.io/helm-charts/"
  chart      = "postee"
  create_namespace = true
  namespace = "trivy-system"
  timeout = 1500
  wait = true

  values = [<<EOF
posteeConfig: |
  name: postee-${var.env}
  max-db-size: 1000MB 
  routes:
  - name: trivy-operator-slack
    actions: [send-slack-msg]
    template: trivy-operator-slack

  templates:
  - name: vuls-slack                  #  Out of the box template for slack
    rego-package:  postee.vuls.slack      #  Slack template REGO package (available out of the box)
  - name: vuls-html                       #  Out of the box HTML template
    rego-package:  postee.vuls.html       #  HTML template REGO package (available out of the box)
  - name: raw-html                        #  Raw message json
    rego-package:  postee.rawmessage.html #  HTML template REGO package (available out of the box)
  - name: legacy                          #  Out of the box legacy Golang template
    legacy-scan-renderer: html
  - name: legacy-slack                    #  Legacy slack template implemented in Golang
    legacy-scan-renderer: slack
  - name: legacy-jira                     #  Legacy jira template implemented in Golang
    legacy-scan-renderer: jira
  - name: custom-email                    #  Example of how to use a template from a Web URL
    url:                                  #  URL to custom REGO file
  - name: raw-json                        # route message "As Is" to external webhook
    rego-package: postee.rawmessage.json
  - name: vuls-cyclonedx                  # export vulnerabilities to CycloneDX XML
    rego-package: postee.vuls.cyclondx
  - name: trivy-operator-jira
    rego-package: postee.trivyoperator.jira
  - name: trivy-operator-slack
    rego-package: postee.trivyoperator.slack
  - name: trivy-operator-dependencytrack
    rego-package: postee.trivyoperator.dependencytrack

  actions:
  - name: stdout
    type: stdout
    enable: true
  - name: send-slack-msg
    type: slack
    enable: true
    url: "${var.trivy.trivyWebhookUrl}"

  rules:
  - name: Initial Access
  - name: Credential Access
  - name: Privilege Escalation
  - name: Defense Evasion
  - name: Persistence

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
