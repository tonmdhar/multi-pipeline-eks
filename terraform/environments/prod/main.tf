module "vpc" {
  source = "../../modules/vpc"

  environment        = local.environment
  project_name       = local.project_name
  vpc_cidr           = local.vpc_cidr
  azs                = local.azs
  private_subnets    = local.private_subnets
  public_subnets     = local.public_subnets
  single_nat_gateway = local.single_nat_gateway
  cluster_name       = local.cluster_name
}

module "eks" {
  source = "../../modules/eks"

  environment         = local.environment
  project_name        = local.project_name
  cluster_name        = local.cluster_name
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  node_instance_types = local.node_instance_types
  node_desired_size   = local.node_desired_size
  node_min_size       = local.node_min_size
  node_max_size       = local.node_max_size
}
