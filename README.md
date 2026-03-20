# AWS Multi-Region HA Infrastructure

Terraform-managed high-availability infrastructure across AWS Tokyo and Osaka regions.  
Built as a portfolio project demonstrating IaC practices and multi-region failover design.

## Design Decisions

**Why multi-region over multi-AZ only?**  
Multi-AZ within a single region protects against AZ-level failures but not region-wide outages.  
This setup adds Osaka as a warm standby, with Route 53 health checks handling automatic failover.

**Why SSM over SSH?**  
EC2 instances have no inbound SSH port open. Session Manager provides secure shell access  
without exposing port 22 or managing key pairs, reducing the attack surface.

**Why HTTP→HTTPS redirect at ALB?**  
Enforcing TLS termination at the load balancer ensures all traffic is encrypted in transit,  
while keeping EC2 instances handling only HTTP internally (no cert management on instances).

## Stack

| Layer | Technology |
|---|---|
| IaC | Terraform |
| Compute | EC2 (Amazon Linux 2023, t3.micro) |
| Load Balancing | ALB (Application Load Balancer) |
| DNS & Failover | Route 53 + Cloudflare |
| TLS | ACM (AWS Certificate Manager) |
| Access | SSM Session Manager (no SSH) |
| Regions | ap-northeast-1 (Tokyo), ap-northeast-3 (Osaka) |

## Infrastructure Layout

```
vpc.tf        VPC, subnets (public x2 per region), IGW, route tables
compute.tf    EC2 instances, AMI via SSM Parameter Store, user_data (Apache)
alb.tf        ALB, target groups, listeners (HTTP redirect + HTTPS forward)
security.tf   Security groups (ALB: 80/443 open, EC2: 80 from ALB only)
dns.tf        Route 53 hosted zone, health checks, Cloudflare NS integration
acm.tf        ACM certificate request and DNS validation
iam.tf        IAM role and instance profile for SSM
variables.tf  Cloudflare token, zone ID, domain name
outputs.tf    ALB DNS names, instance IDs
providers.tf  AWS (tokyo + osaka alias), Cloudflare
```

## Security Posture

- EC2 instances accept HTTP **only from ALB security group** (no direct internet access)
- No SSH port open; instance access via SSM Session Manager
- HTTPS enforced via ALB listener redirect (HTTP 301 → HTTPS)
- TLS certificates managed by ACM with automatic renewal

## Prerequisites

```hcl
# terraform.tfvars
cloudflare_api_token = "YOUR_CLOUDFLARE_API_TOKEN"
cloudflare_zone_id   = "YOUR_CLOUDFLARE_ZONE_ID"
domain_name          = "yourdomain.com"
```

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Status

- [x] VPC / subnet / IGW / route tables (Tokyo + Osaka)
- [x] EC2 multi-AZ (2 instances per region)
- [x] ALB with HTTPS and HTTP redirect
- [x] ACM certificate with DNS validation
- [x] Route 53 health check + failover routing
- [x] SSM access (no SSH)
- [x] Private subnets for EC2

## Future Improvements

- Auto Scaling Group (replace fixed EC2)
- Terraform modules refactor
