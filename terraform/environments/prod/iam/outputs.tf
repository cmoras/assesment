output "irsa_role_arn" {
  description = "ARN of the IAM role for service account"
  value       = module.iam.irsa_role_arn
}

output "irsa_role_name" {
  description = "Name of the IAM role for service account"
  value       = module.iam.irsa_role_name
}
