resource "helm_release" "kyverno" {
  name             = "kyverno"
  repository       = "https://kyverno.github.io/kyverno/"
  chart            = "kyverno"
  version          = "3.0.0-beta.1"
  create_namespace = true
  namespace        = "kyverno"
  timeout          = 1500
  wait = true

  values = [<<EOF
replicaCount: 1
EOF
  ]

  depends_on = [
    helm_release.letsencrypt-cluster-issuer[0]
  ]

  count = var.kyverno.enabled ? 1 : 0
}

resource "kubernetes_cluster_role_binding" "kyverno-cluster-admin-role-binding" {
  metadata {
    name = "kyverno-cluster-admin-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    namespace = "kyverno"
    name = "kyverno-background-controller"
  }
  count = var.kyverno.enabled ? 1 : 0
  depends_on = [
    helm_release.kyverno[0]
  ]
}

resource "kubernetes_cluster_role_binding" "kyverno-cluster-admin-role-binding-2" {
  metadata {
    name = "kyverno-cluster-admin-role-binding-2"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    namespace = "kyverno"
    name = "kyverno-admission-controller"
  }
  count = var.kyverno.enabled ? 1 : 0
  depends_on = [
    helm_release.kyverno[0]
  ]
}

resource "kubernetes_cluster_role_binding" "kyverno-cluster-admin-role-binding-3" {
  metadata {
    name = "kyverno-cluster-admin-role-binding-3"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    namespace = "kyverno"
    name = "kyverno-reports-controller"
  }
  count = var.kyverno.enabled ? 1 : 0
  depends_on = [
    helm_release.kyverno[0]
  ]
}

resource "kubernetes_cluster_role_binding" "kyverno-cluster-admin-role-binding-4" {
  metadata {
    name = "kyverno-cluster-admin-role-binding-4"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    namespace = "kyverno"
    name = "kyverno-cleanup-controller"
  }
  count = var.kyverno.enabled ? 1 : 0
  depends_on = [
    helm_release.kyverno[0]
  ]
}

