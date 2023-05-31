resource "helm_release" "regcred" {
  name       = "regcred"
  repository = "https://colearendt.github.io/helm"
  chart      = "regcred"
  version    = "0.1.0"
  create_namespace = true
  namespace = "vdis"
  timeout = 1500
  wait = true

  values = [<<EOF
nameOverride: 'regcred'
fullnameOverride: 'regcred'
registryCredentials:
  - url: ghcr.io
    username: 'mars-office'
    password: '${var.vdi.githubToken}'
EOF
  ]

  count = var.vdi.enabled ? 1 : 0
}

resource "helm_release" "vdi" {
  for_each = toset(var.vdi.enabled ? var.vdi.vdis : [])
  name       = "vdi-${each.value.name}"
  chart      = "oci://ghcr.io/mars-office/vdi"
  version    = "0.0.20"
  repository_username = "mars-office"
  repository_password = var.vdi.githubToken
  create_namespace = true
  namespace = "vdis"
  timeout = 1500
  wait = true

  values = [<<EOF
vncPassword: ${each.value.password}

imagePullSecrets:
  - name: regcred

ingress:
  enabled: true
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/configuration-snippet: |
      proxy_set_header Authorization $http_authorization;
  hosts:
    - host: ${each.value.name}.vdi.${var.clusterDns}
      paths:
        - path: '/'
          pathType: ImplementationSpecific
  tls:
    - secretName: ${each.value.name}-vdi-ingress-tls
      hosts:
        - ${each.value.name}.vdi.${var.clusterDns}
EOF
  ]

  depends_on = [ 
    helm_release.regcred[0]
   ]
}