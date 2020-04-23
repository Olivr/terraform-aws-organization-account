// Providers
provider "aws" {
  region  = var.aws_default_region
  profile = var.aws_profile
}

provider "github" {
  token        = var.github_token
  organization = var.github_organization
}

terraform {
  required_providers {
    aws    = "~> 2.58"
    tfe    = "~> 0.15.0"
    github = "~> 2.6"
    null   = "~> 2.1"
  }
}
