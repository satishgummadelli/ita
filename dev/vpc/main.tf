provider "aws" {
  region = "eu-west-2"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-vpc.git"

  name = "mycentric_dev"

  cidr = "10.0.0.0/16" 

  azs                 = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  private_subnets     = ["10.0.228.0/22", "10.0.224.0/22", "10.0.220.0/22"]
  public_subnets      = ["10.0.240.0/22", "10.0.236.0/22", "10.0.232.0/22"]
  database_subnets    = ["10.0.244.0/22", "10.0.248.0/22", "10.0.252.0/22"]


  create_database_subnet_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_classiclink             = false
  enable_classiclink_dns_support = false

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
  enable_sns_endpoint              = true
  sns_endpoint_private_dns_enabled = true
  sns_endpoint_security_group_ids  = [data.aws_security_group.default.id]

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
    Environment = "dev"
    Name        = "mycentric_dev"
  }

  vpc_endpoint_tags = {
    Project  = "Secret"
    Endpoint = "true"
  }

}
