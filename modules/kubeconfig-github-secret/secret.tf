resource "github_actions_organization_secret" "kubeconfig_secret" {
  secret_name     = "${upper(var.env)}_KUBECONFIG"
  visibility      = "all"
  plaintext_value = var.kubeconfig
}