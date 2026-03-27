module "tokyo" {
  source = "./modules/region"

  providers = {
    aws = aws
  }

  region_name = "tokyo"
  region_code = "ap-northeast-1"
  vpc_cidr    = "10.0.0.0/16"

  public_subnet_a_cidr = "10.0.1.0/24"
  public_subnet_a_az   = "ap-northeast-1a"
  public_subnet_c_cidr = "10.0.2.0/24"
  public_subnet_c_az   = "ap-northeast-1c"

  private_subnet_a_cidr = "10.0.3.0/24"
  private_subnet_a_az   = "ap-northeast-1a"
  private_subnet_c_cidr = "10.0.4.0/24"
  private_subnet_c_az   = "ap-northeast-1c"

  domain_name          = var.main_domain
  route53_zone_id      = aws_route53_zone.portfolio_sub.zone_id
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
}

module "osaka" {
  source = "./modules/region"

  providers = {
    aws = aws.osaka
  }

  region_name = "osaka"
  region_code = "ap-northeast-3"
  vpc_cidr    = "10.1.0.0/16"

  public_subnet_a_cidr = "10.1.1.0/24"
  public_subnet_a_az   = "ap-northeast-3a"
  public_subnet_c_cidr = "10.1.2.0/24"
  public_subnet_c_az   = "ap-northeast-3c"

  private_subnet_a_cidr = "10.1.3.0/24"
  private_subnet_a_az   = "ap-northeast-3a"
  private_subnet_c_cidr = "10.1.4.0/24"
  private_subnet_c_az   = "ap-northeast-3c"

  domain_name          = var.main_domain
  route53_zone_id      = aws_route53_zone.portfolio_sub.zone_id
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
}
