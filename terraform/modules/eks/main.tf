###############################################
# EKS Cluster
###############################################
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true  # Needed for kubectl from local machine
  }

  # API_AND_CONFIG_MAP avoids lockout (lesson from previous project)
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  # Control plane logging
  enabled_cluster_log_types = var.cluster_log_types

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
  ]

  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    })
}

###############################################
# EKS Node Group (private subnets only)
###############################################
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = var.subnet_ids

  instance_types  = var.node_instance_types
  disk_size       = var.node_disk_size

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure IAM policies are attached before creating nodes
  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr,
  ]

  tags = merge(var.tags, {
    Environment = var.environment
    Name        = "${var.cluster_name}-node-group"
  })
}