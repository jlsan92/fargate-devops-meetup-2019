terraform {
  required_version = "~> 0.11.11"
}

provider "aws" {
  version = "~> 1.54.0"
  region  = "us-east-1"
  profile = "personal"
}

module "fargate" {
  source  = "strvcom/strv-fargate/aws"
  version = "0.4.1"

  name = "devops-meetup"

  services = {
    api = {
      task_definition = "api.json"
      container_port  = 4000
      cpu             = "256"
      memory          = "512"
      replicas        = 3
    }
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "*.juanlsanchez.co"
  validation_method = "DNS"
}

data "aws_route53_zone" "zone" {
  name         = "juanlsanchez.co."
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}