terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.21"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# tokyo region
provider "aws" {
  region = "ap-northeast-1"
}

# osaka region
provider "aws" {
  alias  = "osaka"
  region = "ap-northeast-3"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
