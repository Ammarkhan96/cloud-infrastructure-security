output "s3_bucket_name" {
  description = "Secure S3 bucket name"
  value       = aws_s3_bucket.secure_bucket.bucket
}

output "security_group_id" {
  description = "Secure security group ID"
  value       = aws_security_group.secure_sg.id
}

output "iam_role_name" {
  description = "Secure IAM role name"
  value       = aws_iam_role.secure_role.name
}