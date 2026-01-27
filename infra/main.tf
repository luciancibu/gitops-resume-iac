module "vpc" {
  source = "./modules/vpc"

  name = "dev-vpc"
  cidr = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnets = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]

  azs = [
    "us-east-1a",
    "us-east-1b"
  ]
}

# EKS
module "eks" {
  source = "./modules/eks"

  cluster_name    = "dev-eks"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name           = "node-group-1"
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }

    two = {
      name           = "node-group-2"
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }

  tags = {
    Environment = "dev"
    Project     = "eks"
  }
}

module "ecr_flask" {
  source = "./modules/ecr"
  name   = "resume-flask"
}

module "ecr_nginx" {
  source = "./modules/ecr"
  name   = "resume-nginx"
}