resource "cloudflare_record" "record" {
  for_each = {for r in var.records : r.name => r}
  zone_id = data.cloudflare_zone.zone.id
  name    = each.value.name
  value   = each.value.value
  type    = each.value.type
  proxied = false
  allow_overwrite = true
}
