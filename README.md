# Setup Organization

This terraform script lets you prepare an organization before setting up the environments

## Features

- Setup one account per environment
- Setup each environment
- Setup terraform cloud

## Pre-requisites

- [][aws access key](https://console.aws.amazon.com/iam/home#/security_credentials) (It is highly recommended to create a new AWS account)
- [][github personal token](https://github.com/settings/tokens) with the following permissions: repo, admin:org, admin:repo_hook, admin:org_hook, delete_repo, workflow (It is highly recommended to create a new GitHub account such as `<Your Organization>-bot`)
- [][github organization](https://github.com/account/organizations/new)
- [][terraform cloud personal token](https://app.terraform.io/app/settings/tokens)

## Important notes

- **AWS does not support programmatic deletion of accounts.** This means that if you use this project to create the account structure, terraform is not able to completely destroy it.
- **AWS will rate limit account creation.** This might mean you'll need to restart the provisioning (just re-run `terraform apply`).

## Usage

Initialize Terraform

`terraform init`

Run

`terraform apply`

Once complete, run the init command again to push the current state to Terraform Cloud

`terraform init`

And if there are any errors due to timeouts or other weird stuff, it doesn't hurt to run again

`terraform apply`

## AWS Sub-accounts

| root             | Master account used to create the organizational account structure. Most of the time it should not be used again. |
| ---------------- | ----------------------------------------------------------------------------------------------------------------- |
| identity         | Contains all users and policies                                                                                   |
| audit            | Contains all logs                                                                                                 |
| shared-resources | Contains resources that are shared across other accounts such as AMI's, repositories, etc.                        |
| staging          | Staging environment                                                                                               |
| production       | Production environment                                                                                            |
| testing          | Used for infrastructure automated testing (before deploying new infrastructure on staging/production)             |
| sandbox-\*       | Sandbox environment created for each developer to freely deploy anything they want                                |

## More reading

https://gruntwork.io/guides/foundations/how-to-configure-production-grade-aws-account-structure
