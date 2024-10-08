provider "aws" {
  region = var.region
  version = "~> 3.11"
}

module "network" {
  source       = "./modules/network"
  environment  = var.environment
  default_tags = var.default_tags
}
# I am a comment
module "storage" {
  source         = "./modules/storage"
  private_subnet = module.network.private_subnet
  vpc_id         = module.network.vpc_id
  environment    = var.environment
  default_tags   = var.default_tags
  db_username    = var.db_username
  db_password    = var.db_password
}

module "compute" {
  source = "./modules/compute"
  environment = var.environment
  region = var.region
  elb_target_group_arn = module.network.target_lb_group_arn
  private_subnet = module.network.private_subnet
  public_subnet = module.network.public_subnet
  elb_sg = module.network.target_lb_security_group
  elb_url = module.network.elb_url
}

resource "local_file" "web-access" {
  content  = <<JSON
{
  "fqdn": "${module.network.elb_url}"
}
  JSON
  filename = "./web-access.json"
}
