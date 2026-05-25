output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority" {
  description = "Base64 encoded cluster CA certificate"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "node_group_role_arn" {
  description = "IAM role ARN of the node group"
  value       = aws_iam_role.node_group.arn
}

output "oidc_provider_url" {
  description = "OIDC provider URL (for IRSA - IAM Roles for Service Accounts)"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
