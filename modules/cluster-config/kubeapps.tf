resource "helm_release" "kubeapps" {
  name             = "kubeapps"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "kubeapps"
  version          = "15.1.1"
  create_namespace = true
  namespace        = "kubeapps"
  timeout          = 500
  wait             = true

  values = [<<EOF
ingress:
  enabled: true
  hostname: kubeapps.${var.clusterDns}
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: ${var.certManager.issuer}
  tls: true
  extraTls:
    - hosts:
      - kubeapps.${var.clusterDns}
      secretName: kubeapps-ingress-tls
frontend:
  resources:
    limits:
      cpu: 250m
      memory: 128Mi
    requests:
      cpu: 1m
      memory: 1Mi
dashboard:
  resources:
    limits:
      cpu: 250m
      memory: 128Mi
    requests:
      cpu: 1m
      memory: 1Mi
apprepository:
  resources:
    limits:
      cpu: 250m
      memory: 128Mi
    requests:
      cpu: 1m
      memory: 1Mi
authProxy:
  resources:
    limits:
      cpu: 250m
      memory: 128Mi
    requests:
      cpu: 1m
      memory: 1Mi
pinnipedProxy:
  resources:
    limits:
      cpu: 250m
      memory: 128Mi
    requests:
      cpu: 1m
      memory: 1Mi
postgresql:
  primary:
    persistence:
      enabled: true
  resources:
    limits:
      cpu: 250m
      memory: 128Mi
    requests:
      cpu: 1m
      memory: 1Mi
kubeappsapis:
  resources:
    limits:
      cpu: 250m
      memory: 128Mi
    requests:
      cpu: 1m
      memory: 1Mi
EOF
  ]


  depends_on = [
    helm_release.linkerd-control-plane[0]
  ]

  count = var.kubeapps.enabled ? 1 : 0
}


resource "kubernetes_service_account_v1" "kubeapps-operator-sa" {
  metadata {
    name = "kubeapps-operator"
    namespace = "default"
  }
  count = var.kubeapps.enabled ? 1 : 0
}

resource "kubernetes_cluster_role_binding_v1" "kubeapps-operator-sa-cluster-admin-binding" {
  metadata {
    name = "kubeapps-operator-sa-cluster-admin-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    namespace = "default"
    name = kubernetes_service_account_v1.kubeapps-operator-sa[0].metadata[0].name
  }
  count = var.kubeapps.enabled ? 1 : 0
}

resource "kubernetes_secret_v1" "kubeapps-operator-sa-token" {
  metadata {
    namespace = "default"
    name = "kubeapps-operator-token"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.kubeapps-operator-sa[0].metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"

  count = var.kubeapps.enabled ? 1 : 0
}