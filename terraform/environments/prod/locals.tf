locals {
  environment  = "prod"
  project_name = "atlas-platform"
  region       = "us-east-1"
  cluster_name = "atlas-platform-dev"

  vpc_cidr        = "10.10.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnets  = ["10.10.101.0/24", "10.10.102.0/24"]

  # Dev: cost-saving settings
  single_nat_gateway  = true
  node_instance_types = ["t3.medium"]
  node_desired_size   = 2
  node_min_size       = 1
  node_max_size       = 3
}
