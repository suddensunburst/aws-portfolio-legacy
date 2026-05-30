# AWS マルチリージョン HA インフラ

アクティブ・スタンバイ構成のインフラを Terraform で管理するポートフォリオです。東京リージョンをプライマリ、大阪リージョンをセカンダリとして構成しています。アプリケーションは DynamoDB への読み書きを行うFlask APIです。

## アーキテクチャ

```
Cloudflare → Route 53 → ALB → EC2 → DynamoDB (グローバルテーブル)
```

Route 53 のヘルスチェックにより東京障害時に大阪へフェイルオーバーします。
DynamoDB グローバルテーブルでリージョン間のデータを同期しています。

## スタック

| | |
|---|---|
| IaC | Terraform |
| アプリ | Flask (Python 3.9) |
| コンピュート | EC2 (Amazon Linux 2023, t3.micro) + ASG |
| ロードバランサー | ALB |
| データベース | DynamoDB グローバルテーブル |
| DNS | Route 53 + Cloudflare |

## Well-Architected チェックリスト

### 信頼性
- [x] Route 53 フェイルオーバーによるマルチリージョン アクティブ・スタンバイ（東京プライマリ／大阪セカンダリ）
- [x] 各リージョンで ASG により最低 2 インスタンスを維持
- [x] 複数AZ

### セキュリティ
- [x] EC2 はプライベートサブネットに配置、インターネットからの直接アクセス不可
- [x] SSM Session Manager のみ使用、SSH・踏み台サーバーなし
- [x] SSM・S3・DynamoDB 向けの VPC エンドポイント
- [x] ALB で TLS 終端（ACM 証明書）
- [x] TLS 1.2 以上を強制（ELBSecurityPolicy-TLS13-1-2-2021-06）
- [ ] WAF なし

### コスト最適化
- [x] NAT ゲートウェイなし（VPC エンドポイントを使用）
- [x] t3.micro インスタンス
- [x] DynamoDB は PAY_PER_REQUEST 課金

### パフォーマンス効率
- [x] ALB が複数AZ へトラフィックを分散
- [x] CPU 使用率に基づく ASG のスケールアウト／イン
- [x] DynamoDB グローバルテーブルにより各リージョンから低レイテンシアクセス

### 運用上の優秀性
- [x] CPU 使用率によるスケーリング用 CloudWatch アラーム
- [x] SSH 不要の SSM Session Manager によるインスタンスアクセス
- [ ] CI/CD パイプラインなし（手動デプロイ）
- [ ] 集中ログ管理なし

### 持続可能性
- [ ] 未対応（今回のスコープ外）

## 前提条件

AWS アカウントおよび独自ドメインを持つ Cloudflare アカウントが必要です。デプロイ先は ap-northeast-1（東京）と ap-northeast-3（大阪）です。

```hcl
# terraform.tfvars
cloudflare_api_token = "YOUR_CLOUDFLARE_API_TOKEN"
cloudflare_zone_id   = "YOUR_CLOUDFLARE_ZONE_ID"
main_domain          = "yourdomain.com"
```

## デプロイ手順

S3 バケットは Terraform の管理対象外です。wheels は初回のみアップロードが必要です。

### 1. Apply

```bash
terraform apply
```

### 2. アプリを S3 にアップロード

`{account_id}` は自分の AWS アカウント ID に置き換えてください。

```bash
# wheels のダウンロード（初回のみ）
pip download flask boto3 \
  --platform manylinux2014_x86_64 \
  --python-version 39 \
  --only-binary=:all: \
  -d /tmp/wheels

aws s3 sync /tmp/wheels s3://portfolio-app-{account_id}-tokyo/wheels/
aws s3 sync /tmp/wheels s3://portfolio-app-{account_id}-osaka/wheels/
```

アプリ本体のアップロード。

```bash
aws s3 cp app/main.py s3://portfolio-app-{account_id}-tokyo/app/main.py
aws s3 cp app/main.py s3://portfolio-app-{account_id}-osaka/app/main.py
```

### 3. インスタンスリフレッシュ

```bash
aws autoscaling start-instance-refresh --auto-scaling-group-name portfolio-tokyo-asg --region ap-northeast-1
aws autoscaling start-instance-refresh --auto-scaling-group-name portfolio-osaka-asg --region ap-northeast-3
```

### 4. アプリコードの更新

```bash
aws s3 cp app/main.py s3://portfolio-app-{account_id}-tokyo/app/main.py
aws s3 cp app/main.py s3://portfolio-app-{account_id}-osaka/app/main.py

aws autoscaling start-instance-refresh --auto-scaling-group-name portfolio-tokyo-asg --region ap-northeast-1
aws autoscaling start-instance-refresh --auto-scaling-group-name portfolio-osaka-asg --region ap-northeast-3
```

---

[English](README.en.md)
