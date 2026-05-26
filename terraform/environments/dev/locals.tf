locals {
  environment  = "dev"
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

  # Pipeline settings (add to existing locals block)
  github_owner = "tonmdhar"
  github_repo = "multi-pipeline-eks"
  github_branch = "main"
  codestar_connection_arn = "arn:aws:codeconnections:us-east-1:733508956784:connection/0d9170d0-ca8a-4437-b010-a2c54bd0c04e"

  # Monitoring settings (add to existing locals block)
  alert_emails         = ["tonmdhar@amazon.com"]
  cpu_alarm_threshold  = 80
  memory_alarm_threshold = 85

}