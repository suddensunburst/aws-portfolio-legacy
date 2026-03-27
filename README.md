# AWS Multi-Region HA Infrastructure

Terraform-managed active-standby infrastructure across Tokyo and Osaka.
Portfolio project for AWS SAA certification (→Passed the exam, but I'm still gonna work on it).

## Stack

| Layer | Technology |
|---|---|
| IaC | Terraform |
| Compute | ASG + EC2 (Amazon Linux 2023, t3.micro) |
| Load Balancing | ALB |
| DNS & Failover | Route 53 + Cloudflare |
| TLS | ACM |
| Access | SSM Session Manager |
| Regions | ap-northeast-1 (Tokyo), ap-northeast-3 (Osaka) |

## Infrastructure Layout

```
main.tf       module "tokyo" and module "osaka" calls
dns.tf        Route 53 hosted zone, failover records, Cloudflare NS integration
iam.tf        IAM role and instance profile for SSM (shared)
variables.tf  Cloudflare token, zone ID, domain name
outputs.tf    Route 53 NS records
providers.tf  AWS (tokyo + osaka alias), Cloudflare

modules/region/
  vpc.tf        VPC, subnets (public x2 + private x2), IGW, route tables, VPC endpoints for SSM
  compute.tf    ASG + launch template (min 1 / max 3), CPU-based scaling, CloudWatch alarms
  alb.tf        ALB, target groups, listeners (HTTP redirect + HTTPS forward)
  security.tf   Security groups (ALB: 80/443 open, EC2: 80 from ALB only, VPCE: 443 from VPC)
  acm.tf        ACM certificate request and DNS validation
  variables.tf  Region-specific inputs
  outputs.tf    ALB DNS name/zone ID
```

## Prerequisites

```hcl
# terraform.tfvars
cloudflare_api_token = "YOUR_CLOUDFLARE_API_TOKEN"
cloudflare_zone_id   = "YOUR_CLOUDFLARE_ZONE_ID"
main_domain          = "yourdomain.com"
```
