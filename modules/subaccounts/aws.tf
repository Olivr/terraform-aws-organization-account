/**
 * Create Account
 */

resource "aws_organizations_account" "account" {
  name      = var.aws_account_name
  email     = var.aws_account_email
  role_name = var.aws_role_name
  tags      = local.tags

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name, email, tags]
  }
}

/**
 * Give access to trusted groups
 */

// Create policy for this account
resource "aws_iam_policy" "account_policy" {
  name   = "${title(var.aws_account_name)}AccountAdministratorAccess"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": [
        "arn:aws:iam::${aws_organizations_account.account.id}:role/${var.aws_role_name}"
      ]
    }
  ]
}
EOF
}

// Attach policies to trusted groups
resource "aws_iam_group_policy_attachment" "admin_account_access" {
  for_each = toset(var.aws_trusted_groups)

  group      = each.key
  policy_arn = aws_iam_policy.account_policy.id
}

/**
 * Outputs
 */

output "aws_account_id" {
  value       = aws_organizations_account.account.id
  description = "AWS Account ID"
}
