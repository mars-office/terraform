ociTenancyOcid = "${OCI_TENANCY_OCID}"
ociCompartmentOcid = "${OCI_COMPARTMENT_OCID}"
ociUserOcid = "${OCI_USER_OCID}"
ociPrivateKey = <<-EOT
${OCI_PRIVATE_KEY}
EOT
ociFingerprint = "${OCI_FINGERPRINT}"
ociRegion = "${OCI_REGION}"
sshKeyPrivate = <<-EOT
${SSH_KEY_PRIVATE}
EOT
sshKeyPublic = <<-EOT
${SSH_KEY_PUBLIC}
EOT
ghToken = "${GH_TOKEN}"
ghUsername="${GH_USERNAME}"
ghEmail="${GH_EMAIL}"
newRelicIngestionLicenseKey="${NEW_RELIC_INGESTION_LICENSE_KEY}"
cloudflareToken="${CLOUDFLARE_API_KEY}"
letsEncryptEmail="${LETSENCRYPT_EMAIL}"
kubeappsPassword="${KUBEAPPS_PASSWORD}"
kubernetesDashboardPassword="${KUBERNETES_DASHBOARD_PASSWORD}"
jaegerPassword="${JAEGER_PASSWORD}"
prometheusPassword="${PROMETHEUS_PASSWORD}"
linkerdPassword="${LINKERD_PASSWORD}"
##