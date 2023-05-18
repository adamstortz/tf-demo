locals {
  workload_name = "tf-demo"
  service_name  = "${local.workload_name}-service"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_ecr_repository" "tf_demo_service" {
  name = local.service_name

  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "default_policy" {
  repository = aws_ecr_repository.tf_demo_service.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep only the last 5 untagged images.",
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 5
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
