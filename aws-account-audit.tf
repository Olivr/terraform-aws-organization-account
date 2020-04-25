/**
 * Create audit account
 */

module "audit_account" {
  source = "./modules/subaccounts"

  aws_account_name          = "audit"
  aws_account_email         = var.aws_account_audit_email
  aws_tf_user               = aws_iam_user.users["terraform"].name
  aws_tf_user_access_key_id = aws_iam_access_key.account_keys["terraform"].id
  aws_tf_user_secret_key    = aws_iam_access_key.account_keys["terraform"].secret
  aws_trusted_groups        = [aws_iam_group.admin_group.name]

  tfe_organization   = var.tfe_org_name
  tfe_oauth_token_id = tfe_oauth_client.github.oauth_token_id
  tfe_extra_vars = {
    organization_name = var.aws_org_name
  }

  github_organization = var.github_organization
  github_template     = "olivr-templates/infra-audit"

  tags = local.tags

  module_depends_on = [aws_organizations_organization.org.id]
}

/**
 * Outputs
 */

output "audit_account" {
  value       = module.audit_account
  description = "Audit account"
}
