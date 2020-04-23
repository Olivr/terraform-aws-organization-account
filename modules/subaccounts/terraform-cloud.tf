/**
 * Create Workspace
 */

resource "tfe_workspace" "workspace" {
  name         = local.tfe_workspace
  organization = var.tfe_organization
  auto_apply   = var.tfe_auto_apply

  vcs_repo {
    identifier     = github_repository.repo.full_name
    oauth_token_id = var.tfe_oauth_token_id
  }
}

/**
 * Set variables used by Terraform
 */

data "aws_region" "current" {}

resource "tfe_variable" "aws_default_region" {
  key          = "aws_default_region"
  value        = data.aws_region.current.name
  category     = "terraform"
  workspace_id = tfe_workspace.workspace.id
  description  = "AWS Default Region"
}

resource "tfe_variable" "aws_account_id" {
  key          = "aws_account_id"
  value        = aws_organizations_account.account.id
  category     = "terraform"
  workspace_id = tfe_workspace.workspace.id
  description  = "AWS Account ID"
}

resource "tfe_variable" "aws_role_name" {
  key          = "aws_role_name"
  value        = var.aws_role_name
  category     = "terraform"
  workspace_id = tfe_workspace.workspace.id
  description  = "AWS Role Name"
}

resource "tfe_variable" "aws_access_key_id" {
  key          = "AWS_ACCESS_KEY_ID"
  value        = var.aws_tf_user_access_key_id
  category     = "env"
  workspace_id = tfe_workspace.workspace.id
  description  = "AWS Access Key ID"

  lifecycle {
    ignore_changes = [value]
  }
}

resource "tfe_variable" "aws_secret_access_key" {
  key          = "AWS_SECRET_ACCESS_KEY"
  value        = var.aws_tf_user_secret_key
  category     = "env"
  sensitive    = false
  workspace_id = tfe_workspace.workspace.id
  description  = "AWS Access Key Secret"

  lifecycle {
    ignore_changes = [value]
  }
}

/**
 * There is a race condition when creating Terraform Cloud workspace 
 * variables and a VCS repo at the same time: Terraform Cloud processes
 * the first plan before the variables are created.
 * The workaround is to trigger a second run by commiting something to the VCS repo
 */

resource "github_repository_file" "delete-me" {
  repository     = github_repository.repo.name
  file           = ".delete-me"
  content        = "This file can be deleted"
  commit_message = "Trigger Terraform Cloud run"

  depends_on = [
    tfe_variable.aws_default_region,
    tfe_variable.aws_account_id,
    tfe_variable.aws_role_name,
    tfe_variable.aws_access_key_id,
    tfe_variable.aws_secret_access_key
  ]
}

/**
 * Outputs
 */

output "tfe_workspace" {
  value       = tfe_workspace.workspace.name
  description = "Terraform Cloud workspace"
}

output "tfe_url" {
  value       = "https://app.terraform.io/app/${var.tfe_organization}/workspaces/${tfe_workspace.workspace.name}/runs"
  description = "Terraform Cloud workspace URL"
}

