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

module "ecr" {
  source = "../../modules/ecr"

  environment = local.environment
  project_name = local.project_name
  image_retention_count = 5
}

module "secrets" {
  source = "../../modules/ecr"

  environment = local.environment
  project_name = local.project_name

  secrets = {
    DB_HOST     = "dev-db.cluster-xxx.us-east-1.rds.amazonaws.com"
    DB_USERNAME = "app_user"
    DB_PASSWORD = "CHANGE_ME"
    API_KEY     = "dev-api-key-placeholder"
  }
}

module "pipeline" {
  source = "../../modules/ecr"

  environment = local.environment
  project_name = local.project_name
  github_owner = local.github_owner
  github_repo = local.github_repo
  github_branch = local.github_branch
  codestar_connection_arn = local.codestar_connection_arn
  ecr_repository_url = module.ecr.repository_url
  cluster_name = local.cluster_name
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  require_approval = true   # Manual approval before prod deploy
}