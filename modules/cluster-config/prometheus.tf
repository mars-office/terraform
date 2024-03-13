resource "helm_release" "prometheus-basic-auth-secret" {
  name       = "prometheus-basic-auth-secret"
  repository = "https://helm.sikalabs.io"
  chart      = "basic-auth-secret"
  version    = "1.0.0"
  create_namespace = true
  namespace = "prometheus"
  timeout = 1500
  wait = true

  values = [<<EOF
user: 'admin'
password: '${var.prometheus.adminPassword}'
EOF
  ]

  count = var.prometheus.enabled ? 1 : 0
}

locals {
  remoteWriteNewRelic = var.prometheus.remoteWrite == false || var.newRelic.enabled == false ? "" : <<EOF
  remoteWrite:
    - url: https://metric-api.eu.newrelic.com/prometheus/v1/write?prometheus_server=prometheus-server-${var.env}
      bearer_token: ${var.newRelic.ingestionKey}
      write_relabel_configs:
        - source_labels: [__name__]
          regex: "node_disk_(.*)|node_memory_(.*)|node_cpu_(.*)|node_network_(.*)
          action: keep

EOF
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "25.17.0"
  create_namespace = false
  namespace = "prometheus"
  timeout = 1500
  wait = true

  values = [<<EOF
server:
${local.remoteWriteNewRelic}
  global:
    scrape_interval: 5m
    scrape_timeout: 10s
    evaluation_interval: 10s
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      cert-manager.io/cluster-issuer: ${var.certManager.issuer}
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: prometheus-basic-auth-secret
      nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required Bro'
    hosts:
      - prometheus.${var.clusterDns}
    tls:
      - secretName: prometheus-ingress-tls
        hosts:
          - prometheus.${var.clusterDns}
alertmanager:
  enabled: false
kube-state-metrics:
  enabled: true
extraScrapeConfigs: |-
  - job_name: 'linkerd-controller'
    kubernetes_sd_configs:
    - role: pod
      namespaces:
        names:
        - 'linkerd'
        - 'linkerd-viz'
    relabel_configs:
    - source_labels:
      - __meta_kubernetes_pod_container_port_name
      action: keep
      regex: admin-http
    - source_labels: [__meta_kubernetes_pod_container_name]
      action: replace
      target_label: component

  - job_name: 'linkerd-service-mirror'
    kubernetes_sd_configs:
    - role: pod
    relabel_configs:
    - source_labels:
      - __meta_kubernetes_pod_label_linkerd_io_control_plane_component
      - __meta_kubernetes_pod_container_port_name
      action: keep
      regex: linkerd-service-mirror;admin-http$
    - source_labels: [__meta_kubernetes_pod_container_name]
      action: replace
      target_label: component

  - job_name: 'linkerd-proxy'
    kubernetes_sd_configs:
    - role: pod
    relabel_configs:
    - source_labels:
      - __meta_kubernetes_pod_container_name
      - __meta_kubernetes_pod_container_port_name
      - __meta_kubernetes_pod_label_linkerd_io_control_plane_ns
      action: keep
      regex: ^linkerd-proxy;linkerd-admin;linkerd$
    - source_labels: [__meta_kubernetes_namespace]
      action: replace
      target_label: namespace
    - source_labels: [__meta_kubernetes_pod_name]
      action: replace
      target_label: pod
    # special case k8s' "job" label, to not interfere with prometheus' "job"
    # label
    # __meta_kubernetes_pod_label_linkerd_io_proxy_job=foo =>
    # k8s_job=foo
    - source_labels: [__meta_kubernetes_pod_label_linkerd_io_proxy_job]
      action: replace
      target_label: k8s_job
    # drop __meta_kubernetes_pod_label_linkerd_io_proxy_job
    - action: labeldrop
      regex: __meta_kubernetes_pod_label_linkerd_io_proxy_job
    # __meta_kubernetes_pod_label_linkerd_io_proxy_deployment=foo =>
    # deployment=foo
    - action: labelmap
      regex: __meta_kubernetes_pod_label_linkerd_io_proxy_(.+)
    # drop all labels that we just made copies of in the previous labelmap
    - action: labeldrop
      regex: __meta_kubernetes_pod_label_linkerd_io_proxy_(.+)
    # __meta_kubernetes_pod_label_linkerd_io_foo=bar =>
    # foo=bar
    - action: labelmap
      regex: __meta_kubernetes_pod_label_linkerd_io_(.+)
    # Copy all pod labels to tmp labels
    - action: labelmap
      regex: __meta_kubernetes_pod_label_(.+)
      replacement: __tmp_pod_label_$1
    # Take `linkerd_io_` prefixed labels and copy them without the prefix
    - action: labelmap
      regex: __tmp_pod_label_linkerd_io_(.+)
      replacement:  __tmp_pod_label_$1
    # Drop the `linkerd_io_` originals
    - action: labeldrop
      regex: __tmp_pod_label_linkerd_io_(.+)
    # Copy tmp labels into real labels
    - action: labelmap
      regex: __tmp_pod_label_(.+)
EOF
  ]


  count = var.prometheus.enabled ? 1 : 0

  depends_on = [
    helm_release.prometheus-basic-auth-secret[0]
  ]
}
