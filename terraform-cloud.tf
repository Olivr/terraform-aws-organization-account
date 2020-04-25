/**
 * Create organization
 */

resource "tfe_organization" "org" {
  name  = var.tfe_org_name
  email = var.tfe_org_email
}

/**
 * Create VCS connection with Github
 */

resource "tfe_oauth_client" "github" {
  organization     = tfe_organization.org.name
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.github_token
  service_provider = "github"
}


/**
 * Create configuration for the current terraform backend
 */

resource "tfe_workspace" "setup" {
  name         = local.this_tfe_workspace
  organization = tfe_organization.org.name
  operations   = false
}

resource "null_resource" "tfe_backend" {
  provisioner "local-exec" {
    command = templatefile("${path.module}/init_backend.tpl", {
      tfe_org_name       = tfe_workspace.setup.organization
      tfe_workspace_name = tfe_workspace.setup.name
    })
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf _backend.tf"
  }
}

/**
 * Outputs
 */

output "tfe_organization" {
  value = {
    tfe_organization = tfe_organization.org.name
    tfe_workspace    = tfe_workspace.setup.name
    tfe_url          = "https://app.terraform.io/app/${tfe_organization.org.name}/workspaces/${tfe_workspace.setup.name}/runs"
  }
  description = "Terraform Cloud organization"
}
