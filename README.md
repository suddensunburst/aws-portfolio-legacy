# AWS Multi-Region HA Infrastructure

Terraform-managed active-standby infrastructure across Tokyo and Osaka.
Portfolio project for AWS SAA certification.

## Stack

| Layer | Technology |
|---|---|
| IaC | Terraform |
| Compute | EC2 (Amazon Linux 2023, t3.micro) |
| Load Balancing | ALB |
| DNS & Failover | Route 53 + Cloudflare |
| TLS | ACM |
| Access | SSM Session Manager |
| Regions | ap-northeast-1 (Tokyo), ap-northeast-3 (Osaka) |

## Infrastructure Layout

```
vpc.tf        VPC, subnets (public x2 + private x2 per region), IGW, route tables, VPC endpoints for SSM
compute.tf    EC2 instances (private subnets), AMI via SSM Parameter Store, user_data (Python HTTP server)
alb.tf        ALB, target groups, listeners (HTTP redirect + HTTPS forward)
security.tf   Security groups (ALB: 80/443 open, EC2: 80 from ALB only, VPCE: 443 from VPC)
dns.tf        Route 53 hosted zone, health checks, Cloudflare NS integration
acm.tf        ACM certificate request and DNS validation
iam.tf        IAM role and instance profile for SSM
variables.tf  Cloudflare token, zone ID, domain name
outputs.tf    Route 53 NS records, EC2 private IPs
providers.tf  AWS (tokyo + osaka alias), Cloudflare
```

## Prerequisites

```hcl
# terraform.tfvars
cloudflare_api_token = "YOUR_CLOUDFLARE_API_TOKEN"
cloudflare_zone_id   = "YOUR_CLOUDFLARE_ZONE_ID"
main_domain          = "yourdomain.com"
```
