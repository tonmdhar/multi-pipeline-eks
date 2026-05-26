module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs = var.azs
  private_subnets = var.private_subnets
  public_subnets = var.public_subnets

  # NAT Gateway — outbound internet for private subnets
  # Public subnets exist ONLY for NAT (no EC2/nodes placed here)
  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway
  enable_vpn_gateway = false

  # EKS requires these tags to auto-discover subnets
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy    = "terraform"
  })
}