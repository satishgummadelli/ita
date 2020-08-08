include {
  path = find_in_parent_folders()
}


terraform {
  source = "../../../../modules//recs-pipeline"
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  # Extract out common variables for reuse
  env                         = local.environment_vars.locals.aws_profile
}


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  name = "${local.env}-mycentric"

  cidr = "10.0.0.0/16" 

  azs                 = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets     = ["10.0.0.0/21", "10.0.16.0/21", "10.0.32.0/21"]
  public_subnets      = ["10.0.40.0/22", "10.0.40.0/22", "10.0.8.0/22"]
  database_subnets    = ["10.0.32.0/21", "10.0.12.0/22", "10.0.12.0/22"]


  create_database_subnet_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_classiclink             = true
  enable_classiclink_dns_support = true

  enable_nat_gateway = true
  single_nat_gateway = true

  #enable_vpn_gateway = true

  enable_dhcp_options              = true
  dhcp_options_domain_name         = "service.consul"
  dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]

  # VPC endpoint for S3
  enable_s3_endpoint = true

  # VPC Endpoint for EC2
  enable_ec2_endpoint              = true
  ec2_endpoint_private_dns_enabled = true
  ec2_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # VPC endpoint for SQS
  enable_sqs_endpoint              = true
  sqs_endpoint_private_dns_enabled = true
  sqs_endpoint_security_group_ids  = [data.aws_security_group.default.id]

 # VPC endpoint for SNS
  enable_sqs_endpoint              = true
  sqs_endpoint_private_dns_enabled = true
  sqs_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = [{}]
  default_security_group_egress  = [{}]

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = {
    Owner       = "admin"
    Environment = ${local.env}
    Name        = "${local.env}-mycentric"
  }

  vpc_endpoint_tags = {
    Project  = "Secret"
    Endpoint = "true"
  }

}

