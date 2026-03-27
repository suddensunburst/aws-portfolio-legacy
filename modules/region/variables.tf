variable "region_name"   { type = string }  # "tokyo" / "osaka"
variable "region_code"   { type = string }  # "ap-northeast-1" / "ap-northeast-3"
variable "vpc_cidr"      { type = string }

variable "public_subnet_a_cidr" { type = string }
variable "public_subnet_a_az"   { type = string }
variable "public_subnet_c_cidr" { type = string }
variable "public_subnet_c_az"   { type = string }

variable "private_subnet_a_cidr" { type = string }
variable "private_subnet_a_az"   { type = string }
variable "private_subnet_c_cidr" { type = string }
variable "private_subnet_c_az"   { type = string }

variable "domain_name"          { type = string }
variable "route53_zone_id"      { type = string }
variable "iam_instance_profile" { type = string }
