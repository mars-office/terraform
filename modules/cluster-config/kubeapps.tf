resource "helm_release" "kubeapps-basic-auth-secret" {
  name       = "kubeapps-basic-auth-secret"
  repository = "https://helm.sikalabs.io"
  chart      = "basic-auth-secret"
  version    = "1.0.0"
  create_namespace = true
  namespace = "kubeapps"
  timeout = 500
  wait = true

  values = [<<EOF
user: 'admin'
password: '${var.kubeapps.adminPassword}'
EOF
  ]

  count = var.kubeapps.enabled ? 1 : 0


  depends_on = [
    helm_release.linkerd-control-plane[0]
  ]
}


resource "helm_release" "kubeapps" {
  name             = "kubeapps"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "kubeapps"
  version          = "12.3.2"
  create_namespace = false
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
    nginx.ingress.kubernetes.io/service-upstream: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: kubeapps-basic-auth-secret
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required Bro'
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
    helm_release.kubeapps-basic-auth-secret[0]
  ]

  count = var.kubeapps.enabled ? 1 : 0
}


resource "kubernetes_cluster_role_binding" "kubeapps-default-sa-cluster-admin-role-binding" {
  metadata {
    name = "kubeapps-default-sa-cluster-admin-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    namespace = "kubeapps"
    name = "default"
  }
  count = var.kubeapps.enabled ? 1 : 0
  depends_on = [
    helm_release.kubeapps[0]
  ]
}

resource "kubernetes_cluster_role_binding" "kubeapps-apis-sa-cluster-admin-role-binding" {
  metadata {
    name = "kubeapps-apis-sa-cluster-admin-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    namespace = "kubeapps"
    name = "kubeapps-internal-kubeappsapis"
  }
  count = var.kubeapps.enabled ? 1 : 0
  depends_on = [
    helm_release.kubeapps[0]
  ]
}
