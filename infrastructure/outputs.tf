# VPC
output "vpc" {
  value = {
    id   = "${module.fargate.vpc_id}"
    cidr = "${module.fargate.vpc_cidr_block}"
  }
}

# ECR
output "ecr" {
  value = {
    url = "${module.fargate.ecr_repository_urls}"
  }
}

# ALBs
output "application_load_balancers" {
  value = {
    dns = "${module.fargate.application_load_balancers_dns_names}"
  }
}
