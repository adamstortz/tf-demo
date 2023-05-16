aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com
docker build -t "${aws_ecr_repository.tf_demo_service.repository_url}:latest" -t "${aws_ecr_repository.tf_demo_service.repository_url}:${var.image_version}" -f service/src/Dockerfile service/src/
docker push "${aws_ecr_repository.tf_demo_service.repository_url}:latest"
docker push "${aws_ecr_repository.tf_demo_service.repository_url}:${var.image_version}"