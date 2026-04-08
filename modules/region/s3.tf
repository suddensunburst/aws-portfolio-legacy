data "aws_caller_identity" "current" {}

# resource "aws_s3_bucket" "app" {
#   bucket = "portfolio-app-${data.aws_caller_identity.current.account_id}-${var.region_name}"
# }

# resource "aws_s3_bucket_public_access_block" "app" {
#   bucket = aws_s3_bucket.app.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true

# }

# detached the s3 stuff from terraform management not to "destroy" the bucket
# terraform state rm module.tokyo.aws_s3_bucket.app
# terraform state rm module.tokyo.aws_s3_bucket_public_access_block.app
# terraform state rm module.osaka.aws_s3_bucket.app
# terraform state rm module.osaka.aws_s3_bucket_public_access_block.app
