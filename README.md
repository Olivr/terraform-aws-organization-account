# Setup Organization

This terraform script lets you prepare an organization before setting up the environments

## Features

- Setup an organization and one AWS account per environment
- Setup each environment to use its own GitHub repository and its Terraform Cloud workspace
- Pure Terraform script (no third-party wrapper/CLI)

## Pre-requisites

- [ ] [Terraform CLI](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [ ] [AWS access key](https://console.aws.amazon.com/iam/home#/security_credentials). It is highly recommended to create a **new AWS account**
- [ ] [GitHub organization](https://github.com/account/organizations/new)
- [ ] [GitHub personal token](https://github.com/settings/tokens) with the following permissions: _repo, admin:org, admin:repo_hook, admin:org_hook, delete_repo, workflow_. It is highly recommended to create a **new GitHub account** such as `<Your Organization>-bot`. This user should have at least _member_ access to the organization above
- [ ] [Terraform Cloud personal token](https://app.terraform.io/app/settings/tokens)

## Important notes

- **AWS does not support programmatic deletion of accounts.** This means that if you use this project to create the account structure, terraform is not able to completely destroy it.
- **AWS can rate limit account creation.** This might mean you'll need to retry the provisioning (just re-run `terraform apply`). This could take from a few seconds to a few days at AWS discretion.

## Usage

1. Clone this repo.

2. You can specify a [variable file](#variables-file) or just continue below and answer the Terraform prompts for variables.

3. Initialize Terraform wuth `terraform init`

4. Run Terraform with `terraform apply`

Once complete, run the `terraform init` command again to push the current state to Terraform Cloud (This script generates the backend configuration for you)

> And if there are any errors due to timeouts or other weird stuff, try to run again `terraform apply`

## AWS Sub-accounts

| Account          | Description                                                                                |
| ---------------- | ------------------------------------------------------------------------------------------ |
| master\*         | Master account used to manage the organizational account structure and billing             |
| identity         | Contains all users and policies                                                            |
| audit            | Contains all logs                                                                          |
| shared-resources | Contains resources that are shared across other accounts such as AMI's, repositories, etc. |
| staging          | Staging environment                                                                        |
| production       | Production environment                                                                     |
| testing          | Automated testing environment                                                              |

> The root user of the master account should not be used anymore, it is recommended to delete the security credentials you created to run this script and enable 2FA on this account. If you have admin stuff to do, use the admin user created by this script. Being an IAM user, it can [access all the accounts above as an admin](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html).

## Variables file

Here is an example `terraform.tfvars` file

```hcl
/**
 * General variables
 */

// Default PGP Key to decrypt passwords, in most cases this will be a key configured on your current machine
pgp_key = "keybase:romainbarissat"

/**
 * AWS Variables
 */

aws_profile                        = "acme" // This profile was initiated when I installed the AWS Cli
aws_default_region                 = "us-east-1"
aws_org_name                       = "acme"
aws_account_audit_email            = "audit@acme.com"
aws_account_security_email         = "security@acme.com"
aws_account_shared-resources_email = "shared-resources@acme.com"
aws_account_testing_email          = "testing@acme.com"
aws_account_staging_email          = "staging@acme.com"
aws_account_production_email       = "production@acme.com"


/**
 * Terraform Cloud Variables
 */

tfe_token     = "xxxyyyzzz.atlasv1.xxxyyyzzz"
tfe_org_name  = "acme" // This script will create it
tfe_org_email = "acme@acme.com"


/**
 * Github Variables
 */

github_token        = "xxxyyyzzz" // acme-bot
github_organization = "acme" // This should be created already
```

## Further reading

This setup follows AWS best practices and [here](https://gruntwork.io/guides/foundations/how-to-configure-production-grade-aws-account-structure) is a very good read about a reference architecture by Gruntwork
