# AWS Region for S3 and other resources
provider "aws" {
  region = "eu-west-1"
  alias = "main"
}

# AWS Region for Cloudfront (ACM certs only supports us-east-1)
provider "aws" {
  region = "us-east-1"
  alias = "cloudfront"
}

# Variables
variable "fqdn" {
  description = "The fully-qualified domain name of the resulting S3 website."
  default     = "test.k8s.spirable.com"
}

variable "domain" {
  description = "The domain name."
  default     = "k8s.spirable.com"
}

# Allowed IPs that can directly access the S3 bucket
variable "allowed_ips" {
  type = "list"
  default = [
    "0.0.0.0/0"            # public access
    # "xxx.xxx.xxx.xxx/mm" # restricted
    # "999.999.999.999/32" # invalid IP, completely inaccessible
  ]
}