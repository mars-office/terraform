resource "kubernetes_secret" "regcred" {
  for_each = toset(var.appNamespaces)
  metadata {
    name = "regcred"
    namespace = kubernetes_namespace.app_namespace[each.key].metadata[0].name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      "auths" : {
        "ghcr.io" : {
          username = var.github.username
          password = var.github.token
          auth     = base64encode(join(":", [var.github.username, var.github.token]))
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}