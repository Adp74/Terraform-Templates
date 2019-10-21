output "bucket_domain_name" {
  value       = var.enabled ? join("", aws_s3_bucket.myS3bucket.bucket_domain_name) : ""
  description = "FQDN of bucket"
}

output "bucket_id" {
  value       = var.enabled ? join("", aws_s3_bucket.myS3bucket.id) : ""
  description = "Bucket Name (aka ID)"
}

output "bucket_arn" {
  value       = var.enabled ? join("", aws_s3_bucket.myS3bucket.arn) : ""
  description = "Bucket ARN"
}

output "prefix" {
  value       = var.lifecycle_prefix
  description = "Prefix configured for lifecycle rules"
}

output "enabled" {
  value       = var.enabled
  description = "Is module enabled"
}