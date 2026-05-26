terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
  }
}
###############################################
# S3 Bucket — Pipeline Artifacts
###############################################
resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project_name}-${var.environment}-pipeline-artifacts"

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

###############################################
# CodeBuild — Build (Docker image)
###############################################
resource "aws_codebuild_project" "build" {
  name         = "${var.project_name}-${var.environment}-build"
  description = "Build Docker image for ${var.environment}"
  build_timeout = 15
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"
    privileged_mode = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ECR_REPO_URL"
      value = var.ecr_repository_url
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "us-east-1"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec-build.yml"
  }

  vpc_config {
    security_group_ids = [aws_security_group.codebuild.id]
    subnets = var.subnet_ids
    vpc_id = var.vpc_id
  }

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

###############################################
# CodeBuild — Deploy (kubectl apply)
###############################################
resource "aws_codebuild_project" "deploy" {
  name         = "${var.project_name}-${var.environment}-deploy"
  description = "Deploy to EKS for ${var.environment}"
  build_timeout = 10
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"
    privileged_mode = false
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = var.cluster_name
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }

    environment_variable {
      name  = "ECR_REPO_URL"
      value = var.ecr_repository_url
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec-deploy.yml"
  }

  vpc_config {
    security_group_ids = [aws_security_group.codebuild.id]
    subnets = var.subnet_ids
    vpc_id = var.vpc_id
  }

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

###############################################
# Security Group — CodeBuild
###############################################
resource "aws_security_group" "codebuild" {
  name        = "${var.project_name}-${var.environment}-codebuild-sg"
  description = "Security group for CodeBuild projects"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound (ECR, EKS API, internet)"
  }

  tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-codebuild-sg"
    Environment = var.environment
  })
}

###############################################
# CodePipeline
###############################################
resource "aws_codepipeline" "this" {
  name        = "${var.project_name}-${var.environment}-pipeline"
  role_arn = aws_iam_role.codebuild.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  # Stage 1: Source (GitHub)
  stage {
    name = "Source"

    action {
      category = "Source"
      name     = "GitHub_Source"
      owner    = "AWS"
      provider = "CodeStarSourceConnection"
      version  = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn = var.codestar_connection_arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName = var.github_branch
      }
    }
  }

  # Stage 2: Build (Docker image → ECR)
  stage {
    name = "Build"

    action {
      category = "Build"
      name     = "Build_Image"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"
      output_artifacts = ["build_output"]
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  # Stage 3 (optional): Manual Approval (prod only)
  dynamic "stage" {
    for_each = var.require_approval ? [1] : []
    content {
      name = "Approval"

      action {
        category = "Approval"
        name     = "Manual_Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"

        configuration = {
          CustomData = "Approve deployment to ${var.environment}?"
        }
      }
    }
  }

  # Stage 4: Deploy (kubectl apply to EKS)
  stage {
    name = "Deploy"

    action {
      category = "Build"
      name     = "Deploy_to_EKS"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.deploy.name
      }
    }
  }

  tags = merge(var.tags, {
    Environment = var.environment
  })
}