/**
 * General Variables
 */

variable "pgp_key" {
  type        = string
  description = "Your PGP Key to encrypt/decrypt IAM secrets"
}

/**
 * AWS Variables
 */

variable "aws_admin_users" {
  type        = map(string)
  description = "Organization Admin Users - who can login to the console"
  default     = {}
}

variable "aws_admin_accounts" {
  type        = list(string)
  description = "Organization Admin Accounts - who cannot login to the console but have programmatic access"
  default     = [""]
}

variable "aws_default_region" {
  type        = string
  description = "Default region to deploy to on AWS"
  default     = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "AWS credentials profile to use"
  default     = "default"
}

variable "aws_org_name" {
  type        = string
  description = "Organization name"
}

variable "aws_account_audit_email" {
  type        = string
  description = "Email for audit account"
}

variable "aws_account_identity_email" {
  type        = string
  description = "Email for identity account"
}

variable "aws_account_shared-resources_email" {
  type        = string
  description = "Email for shared-resources account"
}

variable "aws_account_testing_email" {
  type        = string
  description = "Email for testing account"
}

variable "aws_account_staging_email" {
  type        = string
  description = "Email for staging account"
}

variable "aws_account_production_email" {
  type        = string
  description = "Email for production account"
}

/**
 * Terraform Cloud Variables
 */

variable "tfe_token" {
  type        = string
  description = "Terraform Cloud user token"
}

variable "tfe_org_name" {
  type        = string
  description = "Terraform Cloud organization name"
}

variable "tfe_org_email" {
  type        = string
  description = "Terraform Cloud organization email"
}

/**
 * Github Variables
 */

variable "github_token" {
  type        = string
  description = "GitHub personal access token"
}

variable "github_organization" {
  type        = string
  description = "GitHub organization name"
}

/**
 * Local Variables
 */

locals {
  role_name          = "OrganizationAccountAccessRole"
  aws_admin_users    = merge({ admin = var.pgp_key }, var.aws_admin_users)
  aws_admin_accounts = zipmap(compact(concat(["terraform"], var.aws_admin_accounts)), compact(concat(["terraform"], var.aws_admin_accounts)))
  this_tfe_workspace = "_setup"
}

locals {
  tags = {
    Terraform             = "true"
    Automation            = "true"
    TerraformOrganization = var.tfe_org_name
  }
}

locals {
  tags_with_workspace = merge(local.tags, {
    TerraformWorkspace = tfe_workspace.setup.name
  })
}
