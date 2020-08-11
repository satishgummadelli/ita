provider "aws" {
  region = "eu-west-2"
}

##############################################################
# Data sources to get VPC, subnets and security group details
##############################################################
data "aws_vpc" "selected" {
  default = false
  id      = "vpc-07b0a508c6facbc2a"
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.selected.id
}

data "aws_security_group" "selected" {
  #name   = "mycentric_dev"
  id     = "sg-0650f61f45096b623"
}

#####
# DB
#####
module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "centric-dev-postgres"

  engine            = "postgres"
  engine_version    = "10.12"
  instance_class    = "db.t2.large"
  allocated_storage = 5
  storage_encrypted = false

  # kms_key_id        = "arm:aws:kms:<region>:<account id>:key/<kms key id>"
  name = "centric_dev_db"

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  username = "centric_dev_user"

  password = "Centric-dev"
  port     = "5432"

  vpc_security_group_ids = [data.aws_security_group.selected.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # DB subnet group
  subnet_ids = data.aws_subnet_ids.all.ids

  # DB parameter group
  family = "postgres10"

  # DB option group
  major_engine_version = "10"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "centric-dev"

  # Database Deletion Protection
  deletion_protection = false
}
