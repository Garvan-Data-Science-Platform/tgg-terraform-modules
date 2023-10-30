# Initial setup

This directory contains code for initial terraform set up:

- Google storage bucket for remote state
  - deletion protection
  - versioning
  - encryption (GPC does this automatically - at rest)
  - lock files (GPC does this automatically)

## Instructions:

1) Edit `terraform.tfvars` to ensure variable are correct for your project.
2) `terraform init` to initialise terraform providers (this will require authenticating with `gcloud` if you haven't done yet authenticated).
3) `terraform apply` to create initial setup resources.
