locals {
  custom_domain_enabled = var.domain_name != "" && var.hosted_zone_id != ""
  site_bucket_name      = var.domain_name != "" ? "www.${var.domain_name}" : "wedding-site-${data.aws_caller_identity.current.account_id}"
  site_directory        = "${path.root}/${var.website_static_dir}"
  site_content_hash = sha256(join("", [
    for file in fileset(local.site_directory, "**") : "${file}:${filesha256("${local.site_directory}/${file}")}"
  ]))

  default_tags = {
    "Project"   = "Wedding Website"
    "ManagedBy" = "Terraform"
  }
}
