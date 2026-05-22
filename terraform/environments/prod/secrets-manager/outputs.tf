output "secret_arn" {
  description = "ARN of the secret"
  value       = module.secrets.secret_arn
}

output "secret_name" {
  description = "Name of the secret"
  value       = module.secrets.secret_name
}

output "secret_id" {
  description = "ID of the secret"
  value       = module.secrets.secret_id
}
