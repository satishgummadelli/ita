module "main" {
  source = "github.com/riboseinc/terraform-aws-s3-cloudfront-website"

  fqdn = "${var.fqdn}"
  ssl_certificate_arn = "${aws_acm_certificate_validation.cert.certificate_arn}"
  allowed_ips = "${var.allowed_ips}"

  index_document = "index.html"
  error_document = "404.html"

  refer_secret = "${base64sha512("REFER-SECRET-19265125-${var.fqdn}-52865926")}"

  force_destroy = "true"

  # Optional override for PriceClass, defaults to PriceClass_100
  cloudfront_price_class = "PriceClass_200"

  providers = {
    aws.main = aws.main
    aws.cloudfront = aws.cloudfront
  }

  # Optional WAF Web ACL ID, defaults to none.
#  web_acl_id = "${data.terraform_remote_state.site.waf-web-acl-id}"
}


# ACM Certificate generation

resource "aws_acm_certificate" "cert" {
  provider          = "aws.cloudfront"
  domain_name       = "${var.fqdn}"
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  provider = "aws.cloudfront"
  name     = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type     = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id  = "${data.aws_route53_zone.main.id}"
  records  = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl      = 60
}

# Route 53 record for the static site
provider "aws" {
    alias = "dns_zones"

    # ... access keys etc/assume role block
}

data "aws_route53_zone" "main" {
  provider     = "aws.main"
  #name         = "${var.domain}"
  zone_id      = "ZCP3JRBLP5EQZ"
  private_zone = false
}

resource "aws_route53_record" "www" {
  provider = "aws.main"
  zone_id  = "${data.aws_route53_zone.main.zone_id}"
  name     = "www.${data.aws_route53_zone.main.name}"
  allow_overwrite = true
  type     = "A"

  alias {
    name    = "${module.main.cf_domain_name}"
    zone_id = "${module.main.cf_hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate_validation" "cert" {
  provider                = "aws.cloudfront"
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}



