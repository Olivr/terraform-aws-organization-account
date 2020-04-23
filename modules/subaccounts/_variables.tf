/**
 * General Variables
 */

variable "tags" {
  type        = map(string)
  description = "Tags to add to all resources"
  default     = {}
}

/**
 * AWS Variables
 */

variable "aws_account_name" {
  type        = string
  description = "Name of subaccount to create"
}

variable "aws_account_email" {
  type        = string
  description = "Email associated with the new subaccount"
}

variable "aws_role_name" {
  type        = string
  description = "Organization account access role"
  default     = "OrganizationAccountAccessRole"
}

variable "aws_trusted_groups" {
  type        = list(string)
  description = "Organization groups who can access this account"
}

variable "aws_tf_user" {
  type        = string
  description = "IAM user with programmatic access to the subaccount"
}

variable "aws_tf_user_access_key_id" {
  type        = string
  description = "AWS Access key of the IAM user"
}

variable "aws_tf_user_secret_key" {
  type        = string
  description = "AWS Access key secret of the IAM user"
}

/**
 * Terraform Cloud Variables
 */

variable "tfe_organization" {
  type        = string
  description = "Terraform Cloud organization name"
}

variable "tfe_workspace" {
  type        = string
  description = "Terraform Cloud workspace name"
  default     = ""
}

variable "tfe_auto_apply" {
  type        = bool
  description = "If Terraform Cloud should auto-apply the new commits in the GitHub repo"
  default     = true
}

variable "tfe_oauth_token_id" {
  type        = string
  description = "OAuth token ID for Terraform Cloud to connect to GitHub"
}

/**
 * Github Variables
 */

variable "github_organization" {
  type        = string
  description = "GitHub organization name"
}

variable "github_repo" {
  type        = string
  description = "GitHub repo name to be created"
  default     = ""
}

variable "github_repo_private" {
  type        = bool
  description = "Make the new GitHub repo private"
  default     = true
}

variable "github_template" {
  type        = string
  description = "GitHub template to create the repo from"
}

/**
 * Variables Defaults
 */

locals {
  tfe_workspace = var.tfe_workspace != "" ? var.tfe_workspace : var.aws_account_name
  github_repo   = var.github_repo != "" ? var.github_repo : split("/", var.github_template)[1]
}

locals {
  tags = merge({
    Terraform             = "true"
    Automation            = "true"
    TerraformOrganization = var.tfe_organization
    TerraformWorkspace    = local.tfe_workspace
  }, var.tags)
}

/**
 * Forced module dependencies
 * This is a workaround until Terraform supports "depends_on" for modules
 */


variable "module_depends_on" {
  default = [""]
}
