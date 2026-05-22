output "irsa_role_arn" {
  description = "ARN of the IAM role for service account"
  value       = aws_iam_role.irsa.arn
}

output "irsa_role_name" {
  description = "Name of the IAM role for service account"
  value       = aws_iam_role.irsa.name
}
