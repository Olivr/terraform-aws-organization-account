#!/bin/bash

cat <<EOF > _backend.tf
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "${tfe_org_name}"
    workspaces {
      name = "${tfe_workspace_name}"
    }
  }
}
EOF