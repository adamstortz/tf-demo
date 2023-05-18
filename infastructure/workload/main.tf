data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}
data "terraform_remote_state" "stack" {
  backend = "s3"

  config = {
    bucket = "tf-demo-astortz"
    key    = "base"
    region = "us-east-2"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  workload_name = "tf-demo"
  service_name  = "${local.workload_name}-service"
  cluster_name  = "${local.workload_name}-eks-${random_string.suffix.result}"
  github_role   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/oidc_github_terraform"
  ecr_url       = data.terraform_remote_state.stack.outputs.ecr_url
}


resource "aws_security_group" "eks" {
  name        = "eks cluster"
  description = "Allow traffic"
  vpc_id      = module.vpc.vpc_id

}

resource "aws_vpc_security_group_ingress_rule" "eks" {
  security_group_id = aws_security_group.eks.id

  cidr_ipv4   = var.ingress_cidr_block
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 8080
}

resource "aws_vpc_security_group_egress_rule" "eks" {
  security_group_id = aws_security_group.eks.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 0
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name = "${local.workload_name}-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.1"

  cluster_name    = local.cluster_name
  cluster_version = "1.24"

  vpc_id                                = module.vpc.vpc_id
  subnet_ids                            = module.vpc.private_subnets
  cluster_endpoint_public_access        = true
  cluster_additional_security_group_ids = [aws_security_group.eks.id]

  kms_key_administrators = [
    local.github_role,
    "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/AWSReservedSSO_AdministratorAccess_21201f2554c485ff/astortz"
  ]
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    main = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }

  }
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = local.github_role
      username = "github"
      groups   = ["system:masters"]
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

resource "kubernetes_namespace" "workload" {
  metadata {
    name = local.workload_name
  }
}
resource "kubernetes_deployment" "workload" {
  metadata {
    name      = local.service_name
    namespace = kubernetes_namespace.workload.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = local.service_name
      }
    }
    template {
      metadata {
        labels = {
          app = local.service_name
        }
      }
      spec {
        container {
          image = "${local.ecr_url}:${var.image_version}"
          name  = local.service_name
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "workload" {
  metadata {
    name      = local.service_name
    namespace = kubernetes_namespace.workload.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.workload.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 8080
    }
  }
}