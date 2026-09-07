# =========================================================
# VPC
# =========================================================

resource "aws_vpc" "security_demo_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "security-demo-vpc"
  }
}


# =========================================================
# SECURE S3 BUCKET
# =========================================================

resource "aws_s3_bucket" "secure_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "secure-security-bucket"
    Environment = "security-demo"
  }
}


# ---------------------------------------------------------
# S3 PUBLIC ACCESS BLOCK
# ---------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "secure_bucket_public_access" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# ---------------------------------------------------------
# S3 ENCRYPTION
# ---------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "secure_bucket_encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# ---------------------------------------------------------
# S3 VERSIONING
# ---------------------------------------------------------

resource "aws_s3_bucket_versioning" "secure_bucket_versioning" {
  bucket = aws_s3_bucket.secure_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}


# ---------------------------------------------------------
# S3 LIFECYCLE
# ---------------------------------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "secure_bucket_lifecycle" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    id     = "secure-bucket-lifecycle"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}


# =========================================================
# SECURE SECURITY GROUP
# =========================================================

resource "aws_security_group" "secure_sg" {
  name        = "secure-security-group"
  description = "Secure security group with restricted inbound and outbound traffic"
  vpc_id      = aws_vpc.security_demo_vpc.id

  # No inbound traffic by default

  # Allow HTTPS outbound traffic
  egress {
    description = "Allow HTTPS outbound traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "secure-security-group"
  }
}


# =========================================================
# VPC FLOW LOGS
# =========================================================

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/security-demo-flow-logs"
  retention_in_days = 30

  tags = {
    Name = "security-demo-flow-logs"
  }
}


# ---------------------------------------------------------
# IAM ROLE FOR VPC FLOW LOGS
# ---------------------------------------------------------

resource "aws_iam_role" "flow_logs_role" {
  name = "security-demo-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}


# ---------------------------------------------------------
# IAM POLICY FOR VPC FLOW LOGS
# ---------------------------------------------------------

resource "aws_iam_role_policy" "flow_logs_policy" {
  name = "security-demo-flow-logs-policy"
  role = aws_iam_role.flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
      }
    ]
  })
}


# ---------------------------------------------------------
# ENABLE VPC FLOW LOGS
# ---------------------------------------------------------

resource "aws_flow_log" "security_demo_flow_log" {
  iam_role_arn    = aws_iam_role.flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.security_demo_vpc.id

  tags = {
    Name = "security-demo-vpc-flow-log"
  }
}


# =========================================================
# SECURE IAM ROLE
# =========================================================

resource "aws_iam_role" "secure_role" {
  name = "secure-devsecops-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "secure-devsecops-role"
  }
}


# =========================================================
# LEAST PRIVILEGE IAM POLICY
# =========================================================

resource "aws_iam_role_policy" "secure_policy" {
  name = "least-privilege-policy"
  role = aws_iam_role.secure_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.secure_bucket.arn
      },
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.secure_bucket.arn}/*"
      }
    ]
  })
}