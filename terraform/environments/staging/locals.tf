locals {
  environment  = "prod"
  project_name = "atlas-platform"
  region       = "us-east-1"
  cluster_name = "atlas-platform-prod"

  vpc_cidr        = "10.30.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
  public_subnets  = ["10.30.101.0/24", "10.30.102.0/24", "10.30.103.0/24"]

  # Prod: high availability settings
  single_nat_gateway  = false
  node_instance_types = ["t3.large"]
  node_desired_size   = 3
  node_min_size       = 3
  node_max_size       = 6
}
