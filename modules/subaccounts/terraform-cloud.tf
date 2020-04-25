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

resource "tfe_variable" "tfe_organization" {
  key          = "tfe_organization"
  value        = var.tfe_organization
  category     = "terraform"
  workspace_id = tfe_workspace.workspace.id
  description  = "Organization name"
}

resource "tfe_variable" "tfe_workspace" {
  key          = "tfe_workspace"
  value        = tfe_workspace.workspace.name
  category     = "terraform"
  workspace_id = tfe_workspace.workspace.id
  description  = "Workspace name"
}

resource "tfe_variable" "tfe_extra_vars" {
  for_each = var.tfe_extra_vars

  key          = each.key
  value        = each.value
  category     = "terraform"
  workspace_id = tfe_workspace.workspace.id
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
  sensitive    = true
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
 * The workaround is to trigger a second run by calling the API with Curl
 */

data "tfe_team" "owners" {
  name         = "owners"
  organization = var.tfe_organization
}

resource "tfe_team_token" "owner" {
  team_id = data.tfe_team.owners.id
}

resource "null_resource" "tfe_run" {
  provisioner "local-exec" {
    command = "curl -s --header \"Authorization: Bearer ${tfe_team_token.owner.token}\" --header \"Content-Type: application/vnd.api+json\" --request POST --data '{\"data\":{\"attributes\":{\"message\":\"Triggered from Terraform\"},\"type\":\"runs\",\"relationships\":{\"workspace\":{\"data\":{\"id\": \"${tfe_workspace.workspace.id}\"}}}}}' https://app.terraform.io/api/v2/runs > /dev/null"
  }

  depends_on = [
    tfe_variable.aws_default_region,
    tfe_variable.aws_account_id,
    tfe_variable.aws_role_name,
    tfe_variable.aws_access_key_id,
    tfe_variable.aws_secret_access_key,
    tfe_variable.tfe_organization,
    tfe_variable.tfe_workspace,
    tfe_variable.tfe_extra_vars
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

