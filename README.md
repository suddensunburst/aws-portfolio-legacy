# AWS Multi-Region HA Infrastructure

Terraform-managed active-standby infrastructure across Tokyo and Osaka. The app is a simple Flask API that reads and writes to DynamoDB.

## Architecture

```
Cloudflare → Route 53 → ALB → EC2 → DynamoDB (Global Table)
```

Route 53 failover with health checks: Tokyo (primary) / Osaka (secondary)
DynamoDB Global Table replicates between regions.

## Stack

| | |
|---|---|
| IaC | Terraform |
| App | Flask (Python 3.9) |
| Compute | EC2 (Amazon Linux 2023, t3.micro) + ASG |
| Load Balancer | ALB |
| Database | DynamoDB Global Table |
| DNS | Route 53 + Cloudflare |

## Well-Architected Checklist

### Reliability
- [x] Multi-region active-standby with Route 53 failover (Tokyo primary, Osaka secondary)
- [x] ASG ensures minimum one instance per region
- [ ] No multi-AZ within a region (cost)

### Security
- [x] EC2 in private subnets, no direct internet access
- [x] SSM Session Manager only, no SSH, no bastion host
- [x] VPC endpoints for SSM, S3, DynamoDB
- [x] ALB handles TLS termination (ACM certificate)
- [x] TLS 1.2+ enforced (ELBSecurityPolicy-TLS13-1-2-2021-06)
- [ ] No WAF

### Cost Optimization
- [x] No NAT gateway (replaced by VPC endpoints)
- [x] t3.micro instances
- [x] PAY_PER_REQUEST billing on DynamoDB

### Performance Efficiency
- [x] ALB distributes traffic across AZs
- [x] ASG scales out/in based on CPU utilization
- [x] DynamoDB Global Table (low-latency access from each region)

### Operational Excellence
- [x] CloudWatch alarms for scaling on CPU utilization
- [x] SSM Session Manager for instance access without SSH
- [ ] No CI/CD pipeline (manual)
- [ ] No centralized logging

### Sustainability
- [ ] Not addressed (out of scope)

## Prerequisites

Requires an AWS account and a Cloudflare account with a registered domain. Deploys to ap-northeast-1 (Tokyo) and ap-northeast-3 (Osaka).

```hcl
# terraform.tfvars
cloudflare_api_token = "YOUR_CLOUDFLARE_API_TOKEN"
cloudflare_zone_id   = "YOUR_CLOUDFLARE_ZONE_ID"
main_domain          = "yourdomain.com"
```

## Deployment

S3 buckets are excluded from Terraform state. Wheels only need to be uploaded once.

### 1. Apply

```bash
terraform apply
```

### 2. Upload app to S3

Replace `{account_id}` with your AWS account ID.
Download wheels (first time only).

```bash
pip download flask boto3 \
  --platform manylinux2014_x86_64 \
  --python-version 39 \
  --only-binary=:all: \
  -d /tmp/wheels

aws s3 sync /tmp/wheels s3://portfolio-app-{account_id}-tokyo/wheels/
aws s3 sync /tmp/wheels s3://portfolio-app-{account_id}-osaka/wheels/
```

Upload app.

```bash
aws s3 cp app/main.py s3://portfolio-app-{account_id}-tokyo/app/main.py
aws s3 cp app/main.py s3://portfolio-app-{account_id}-osaka/app/main.py
```

### 3. Instance refresh

```bash
aws autoscaling start-instance-refresh --auto-scaling-group-name portfolio-tokyo-asg --region ap-northeast-1
aws autoscaling start-instance-refresh --auto-scaling-group-name portfolio-osaka-asg --region ap-northeast-3
```

### 4. Update app code

```bash
aws s3 cp app/main.py s3://portfolio-app-{account_id}-tokyo/app/main.py
aws s3 cp app/main.py s3://portfolio-app-{account_id}-osaka/app/main.py

aws autoscaling start-instance-refresh --auto-scaling-group-name portfolio-tokyo-asg --region ap-northeast-1
aws autoscaling start-instance-refresh --auto-scaling-group-name portfolio-osaka-asg --region ap-northeast-3
```
