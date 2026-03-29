# AWS Multi-Region HA Infrastructure

Terraform-managed active-standby infrastructure across Tokyo and Osaka.
Portfolio project for AWS SAA certification (→Passed the exam, but I'm still gonna work on it).

## Stack

| Layer | Technology |
|---|---|
| IaC | Terraform |
| Compute | ASG + EC2 (Amazon Linux 2023, t3.micro) |
| Load Balancing | ALB |
| DNS & Failover | Cloudflare + Route 53 |
| TLS | ACM |
| Access | SSM Session Manager |
| Regions | ap-northeast-1 (Tokyo), ap-northeast-3 (Osaka) |

## Infrastructure Layout

```
main.tf       module "tokyo" and module "osaka"
dns.tf        Route 53 hosted zone, failover, Cloudflare integration
iam.tf        IAM role and instance profile for SSM
variables.tf  Cloudflare token, zone ID, domain name
outputs.tf    Route 53 NS records
providers.tf  AWS, Cloudflare

modules/region/
  vpc.tf        VPC, subnets (public x2 + private x2), IGW, route tables, VPC endpoints for SSM
  compute.tf    ASG + launch template (min 1 / max 3), CPU-based scaling, CloudWatch alarms
               # desired=1 for now for cost reasons. AZ-level redundancy is intentionally omitted;
               # cross-region failover via Route 53 covers region-level HA.
  alb.tf        ALB, target groups, listeners (HTTP redirect + HTTPS forward)
  security.tf   Security groups (ALB: 80/443 open, EC2: 80 from ALB only, VPCE: 443 from VPC)
  acm.tf        ACM certificate request and DNS validation
  variables.tf  Region-specific inputs
  outputs.tf    ALB DNS name/zone ID (consumed by root dns.tf)
```

## Prerequisites

```hcl
# terraform.tfvars
cloudflare_api_token = "YOUR_CLOUDFLARE_API_TOKEN"
cloudflare_zone_id   = "YOUR_CLOUDFLARE_ZONE_ID"
main_domain          = "yourdomain.com"
```
