provider "aws" {
  region = local.region
}

locals {
  name   = "hf-cluster"
  region = "us-east-1"

  vpc_cidr = {{vpc-cidr}}
  azs      = ["us-east-1a", "us-east-1b"]

  public_subnets  = [{{public-subnet-1}}, {{public-subnet-2}}]
  private_subnets = [{{private-subnet-1}}, {{private-subnet-2]
  intra_subnets   = [{{infra-subnet-1, {{infra-subnet-2}}]

  tags = {
    Example = local.name
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnets   = local.intra_subnets

  enable_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t2.micro"]

    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    ascode-cluster-wg = {
      min_size     = 3
      max_size     = 6
      desired_size = 3

      instance_types = ["t2.micro"]
      capacity_type  = "SPOT"

      tags = {
        ExtraTag = "hf-app"
      }
    }
  }

  tags = local.tags
}
