output "ecr_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.tf_demo_service.repository_url
}