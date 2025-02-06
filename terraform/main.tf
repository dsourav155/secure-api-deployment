module "vpc" {
  source         = "./modules/vpc"
  vpc_cidr       = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  azs            = ["us-east-1a", "us-east-1b"]
  cluster_name   = "secure-api-cluster"
}

module "iam" {
  source = "./modules/iam"
}

module "eks" {
  source            = "./modules/eks"
  cluster_name      = "secure-api-cluster"
  eks_role_arn      = module.iam.eks_cluster_role_arn
  eks_node_role_arn = module.iam.eks_node_role_arn
  subnet_ids        = module.vpc.public_subnets
  vpc_id            = module.vpc.vpc_id
}

output "eks_cluster_id" {
  value = module.eks.eks_cluster_id
}
