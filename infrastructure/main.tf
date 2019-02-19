# TERRAFORM CONFIG

terraform {
  required_version = "~> 0.11.11"
}

provider "aws" {
  version = "~> 1.54.0"
  region  = "us-east-1"
  profile = "personal"
}

# VARIABLES

variable "naked-domain" {
  default = "juanlsanchez.co"
}

# RESOURCES

module "fargate" {
  source  = "strvcom/fargate/aws"
  version = "0.7.3"

  name = "devops-meetup"

  services = {
    api = {
      task_definition = "api.json"
      container_port  = 3000
      cpu             = "256"
      memory          = "512"
      replicas        = 3

      acm_certificate_arn = "${data.aws_acm_certificate.cert.arn}"
    }
  }
}

data "aws_acm_certificate" "cert" {
  domain = "*.${var.naked-domain}"
}

data "aws_route53_zone" "this" {
  name         = "${var.naked-domain}."
  private_zone = false
}

resource "aws_route53_record" "subdomain" {
  name    = "devops-meetup.${var.naked-domain}"
  zone_id = "${data.aws_route53_zone.this.id}"
  type    = "A"

  alias {
    name                   = "${module.fargate.application_load_balancers_dns_names[0]}"
    zone_id                = "${module.fargate.application_load_balancers_zone_ids[0]}"
    evaluate_target_health = true
  }
}
