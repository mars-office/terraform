resource "helm_release" "kubernetes-dashboard-basic-auth-secret" {
  name             = "kubernetes-dashboard-basic-auth-secret"
  repository       = "https://helm.sikalabs.io"
  chart            = "basic-auth-secret"
  version          = "1.0.0"
  create_namespace = true
  namespace        = "kubernetes-dashboard"
  timeout          = 500
  wait = true
  values = [<<EOF
user: 'admin'
password: '${var.kubernetesDashboard.adminPassword}'
EOF
  ]

  count = var.kubernetesDashboard.enabled ? 1 : 0


  depends_on = [
    helm_release.linkerd-control-plane[0]
  ]
}


resource "helm_release" "kubernetes-dashboard" {
  name             = "kubernetes-dashboard"
  repository       = "https://kubernetes.github.io/dashboard/"
  chart            = "kubernetes-dashboard"
  version          = "7.1.2"
  create_namespace = false
  namespace        = "kubernetes-dashboard"
  timeout          = 500
  wait = true

  values = [<<EOF
nginx:
  enabled: false
cert-manager:
  enabled: false
metricsScraper:
  enabled: true
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: ${var.certManager.issuer}
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: kubernetes-dashboard-basic-auth-secret
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required Bro'
  hosts:
    - dashboard.${var.clusterDns}
  tls:
    - secretName: kubernetes-dashboard-ingress-tls
      hosts:
        - dashboard.${var.clusterDns}
resources:
  requests:
    cpu: 1m
    memory: 1Mi
  limits:
    cpu: 2
    memory: 200Mi
protocolHttp: true
extraArgs:
  - '--enable-skip-login'
  - '--insecure-bind-address=0.0.0.0'
  - '--enable-insecure-login'
  - '--disable-settings-authorizer'
serviceAccount:
  create: true
  name: kubernetes-dashboard
EOF
  ]

  depends_on = [
    helm_release.kubernetes-dashboard-basic-auth-secret[0]
  ]

  count = var.kubernetesDashboard.enabled ? 1 : 0
}

resource "kubernetes_cluster_role_binding" "kubernetes-dashboard-cluster-admin-role-binding" {
  metadata {
    name = "kubernetes-dashboard-cluster-admin-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    namespace = "kubernetes-dashboard"
    name = "kubernetes-dashboard"
  }
  count = var.kubernetesDashboard.enabled ? 1 : 0
  depends_on = [
    helm_release.kubernetes-dashboard[0]
  ]
}
