# create a role for ssm
resource "aws_iam_role" "ssm_role" {
  name = "portfolio-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# attach the management policy to the role
resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# instance profile
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "portfolio-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

# dynamodb access
data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "dynamodb_access" {
  name = "portfolio-dynamodb-access"
  role = aws_iam_role.ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem",
        "dynamodb:Scan",
        "dynamodb:Query"
      ]
      Resource = [
        "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/portfolio-messages"
      ]
    }]
  })
}
