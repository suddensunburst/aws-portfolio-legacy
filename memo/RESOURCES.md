# Terraform Resource Reference

---

## VPC

```
aws_vpc
aws_subnet
aws_internet_gateway
aws_route_table
aws_route_table_association
```

## SSM Session Manager アクセス（SSH不要）

```
# VPCエンドポイント（プライベートサブネットから接続する場合）
aws_vpc_endpoint  x3 (ssm / ssmmessages / ec2messages)
aws_security_group  (VPCエンドポイント用: 443 from VPC CIDR)

# IAM
aws_iam_role
aws_iam_role_policy_attachment  (AmazonSSMManagedInstanceCore)
aws_iam_instance_profile
```

## EC2（固定台数の場合）

```
data.aws_ssm_parameter  (AMI取得)
aws_instance
aws_security_group  (web用: 80 from ALB SG only)
```

## Auto Scaling Group

```
data.aws_ssm_parameter
aws_launch_template
aws_autoscaling_group
aws_security_group

# CPUスケーリング
aws_autoscaling_policy  x2 (scale-out / scale-in)
aws_cloudwatch_metric_alarm  x2 (cpu-high / cpu-low)
```

## ALB（HTTP→HTTPS redirect）

```
aws_lb
aws_lb_target_group
aws_lb_listener  ×2 (80 redirect / 443 forward)
aws_security_group  (ALB用: 80/443 from 0.0.0.0/0)

# EC2固定台数の場合
aws_lb_target_group_attachment  xインスタンス数

# ASGの場合
→ aws_autoscaling_group の target_group_arns で紐付け（attachmentは不要）
```

## ACM証明書（DNS検証）

```
aws_acm_certificate
aws_route53_record  (CNAMEレコード、for_each)
aws_acm_certificate_validation
```

## Route 53 フェイルオーバー

```
aws_route53_zone
aws_route53_record  ×2 (PRIMARY / SECONDARY、evaluate_target_health = true)
```

## Cloudflare NS委任

```
cloudflare_record  (NSレコード、count = 4)
```

## Terraform モジュール化（プロバイダー渡し）

```
# ルート
module "xxx" {
  source    = "./modules/yyy"
  providers = { aws = aws.alias }
  ...
}

# モジュール側 versions.tf
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
```
