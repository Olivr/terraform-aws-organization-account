/**
 * Create Repository from template
 */

data "github_repository" "template" {
  full_name = var.github_template
}

resource "github_repository" "repo" {
  name        = local.github_repo
  description = data.github_repository.template.description
  private     = var.github_repo_private
  topics      = ["cloud", "terraform", "aws", "infrastructure-as-code"]

  template {
    owner      = split("/", var.github_template)[0]
    repository = split("/", var.github_template)[1]
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name, description, private, topics]
  }
}

/**
 * Outputs
 */

output "gh_repo_name" {
  value       = github_repository.repo.full_name
  description = "GitHub repo name"
}

output "gh_repo_url" {
  value       = github_repository.repo.html_url
  description = "GitHub repo URL"
}
