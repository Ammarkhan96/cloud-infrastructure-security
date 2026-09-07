# ---------------------------------------------------------
# INSECURE S3 BUCKET
# ---------------------------------------------------------

resource "aws_s3_bucket" "insecure_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "insecure_bucket_public_access" {
  bucket = aws_s3_bucket.insecure_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# ---------------------------------------------------------
# INSECURE SECURITY GROUP
# ---------------------------------------------------------

resource "aws_vpc" "security_demo_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "security-demo-vpc"
  }
}

resource "aws_security_group" "insecure_sg" {
  name        = "insecure-security-group"
  description = "Intentionally insecure security group"
  vpc_id      = aws_vpc.security_demo_vpc.id

  ingress {
    description = "SSH open to the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP open to the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "insecure-security-group"
  }
}


# ---------------------------------------------------------
# INSECURE IAM ROLE
# ---------------------------------------------------------

resource "aws_iam_role" "insecure_role" {
  name = "insecure-devsecops-role"

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
}


# ---------------------------------------------------------
# OVER-PERMISSIVE IAM POLICY
# ---------------------------------------------------------

resource "aws_iam_role_policy" "insecure_policy" {
  name = "over-permissive-policy"
  role = aws_iam_role.insecure_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}