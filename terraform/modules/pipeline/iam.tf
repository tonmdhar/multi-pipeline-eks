###############################################
# IAM Role — CodePipeline
###############################################
resource "aws_iam_role" "codepipeline" {
  name = "${var.project_name}-${var.environment}-pipeline-role"

  assume_role_policy = jsondecode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "codepipeline.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "${var.project_name}-${var.environment}-pipeline-policy"
  role = aws_iam_role.codepipeline.id

  policy = jsondecode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow"
        Resource: [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
        "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetBucketVersioning"
        ]
      },
      {
        Effect: "Allow"
        Action: [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource: "*"
      },
      {
        Effect: "Allow"
        Action: ["codestar-connections:UseConnection"]
        Resource: [var.codestar_connection_arn]
      }
    ]
  })
}

###############################################
# IAM Role — CodeBuild
###############################################
resource "aws_iam_role" "codebuild" {
  name = "${var.project_name}-${var.environment}-codebuild-role"

  assume_role_policy = jsondecode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "codebuild.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "codebuild" {
  name = "${var.project_name}-${var.environment}-codebuild-policy"
  role = aws_iam_role.codebuild.id

  policy = jsondecode({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow"
        Resource: "*"
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        Effect: "Allow"
        Action: [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource: "${aws_s3_bucket.artifacts.arn}/*"
      },
      {
        Effect: "Allow"
        Action: [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource: "*"
      },
      {
        Effect: "Allow"
        Action: ["eks:DescribeCluster"]
        Resource: "*"
      },
      {
        Effect: "Allow"
        Action: [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeVpcs",
          "ec2:CreateNetworkInterfacePermission"
        ]
        Resource: "*"
      }
    ]
  })
}