# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  aws_profile = "dev"
  aws_account = "975165675840"
  account_name ="centrichelth-dev"
}


