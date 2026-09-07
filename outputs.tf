output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.insecure_bucket.bucket
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.insecure_sg.id
}

output "iam_role_name" {
  description = "IAM role name"
  value       = aws_iam_role.insecure_role.name
}