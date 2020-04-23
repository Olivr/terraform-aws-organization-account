/*
 * Create organization
 */

resource "aws_organizations_organization" "org" {
}

/**
 * Create organization admins
 */

// Create organization admin users & accounts
resource "aws_iam_user" "users" {
  for_each = merge(local.aws_admin_users, local.aws_admin_accounts)

  name          = each.key
  force_destroy = true
  tags          = local.tags_with_workspace
}

// Create Console access for organization admin users
resource "aws_iam_user_login_profile" "user_profiles" {
  for_each = local.aws_admin_users

  user                    = aws_iam_user.users[each.key].name
  pgp_key                 = each.value != "" ? each.value : var.pgp_key
  password_reset_required = false
}

// Create Programmatic access for organization admin accounts
resource "aws_iam_access_key" "account_keys" {
  for_each = local.aws_admin_accounts
  user     = aws_iam_user.users[each.key].name
  pgp_key  = var.pgp_key
}

// Create organization admin group
resource "aws_iam_group" "admin_group" {
  name = "Administrators"
}

// Create organization admin group policy
resource "aws_iam_group_policy_attachment" "admin_policy" {
  group      = aws_iam_group.admin_group.id
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

// Attach each admin user/account to the admin group
resource "aws_iam_user_group_membership" "users_groups" {
  for_each = merge(local.aws_admin_users, local.aws_admin_accounts)

  user   = aws_iam_user.users[each.key].name
  groups = [aws_iam_group.admin_group.name]
}

/**
 * Outputs
 */

output "aws_users" {
  value = [
    for value in aws_iam_user_login_profile.user_profiles : tomap({
      user               = value.user,
      encrypted_password = "echo '${value.encrypted_password}' | base64 --decode | keybase pgp decrypt"
    })
  ]
  description = "AWS organization admin users"
}

output "aws_accounts" {
  value = [
    for value in aws_iam_access_key.account_keys : tomap({
      user                  = value.user,
      aws_access_key_id     = value.id,
      aws_secret_access_key = value.encrypted_secret != null ? "echo '${value.encrypted_secret}' | base64 --decode | keybase pgp decrypt" : value.secret
    })
  ]
  description = "AWS organization admin accounts"
}

output "aws_organization" {
  value = {
    aws_account_id     = aws_organizations_organization.org.master_account_id
    aws_role_name      = local.role_name
    aws_default_region = var.aws_default_region
  }
  description = "AWS organization"
}
