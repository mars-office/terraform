resource "kubernetes_namespace" "testns" {
  metadata {
    name = "testns"
  }
}