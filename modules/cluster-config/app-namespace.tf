resource "kubernetes_namespace" "app_namespace" {
  for_each = toset(var.appNamespaces)
  metadata {
    name = each.value
  }
}
