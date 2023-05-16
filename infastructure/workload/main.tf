data "aws_availability_zones" "available" {}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  workload_name = "tf-demo"
  service_name  = "${local.workload_name}-service"
  cluster_name  = "${local.workload_name}-eks-${random_string.suffix.result}"
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

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "19.13.1"

#   cluster_name    = local.cluster_name
#   cluster_version = "1.24"

#   vpc_id                         = module.vpc.vpc_id
#   subnet_ids                     = module.vpc.private_subnets
#   cluster_endpoint_public_access = true

#   eks_managed_node_group_defaults = {
#     ami_type = "AL2_x86_64"
#   }

#   eks_managed_node_groups = {
#     main = {
#       name = "node-group-1"

#       instance_types = ["t3.small"]

#       min_size     = 1
#       max_size     = 2
#       desired_size = 1
#     }

#   }
# }
