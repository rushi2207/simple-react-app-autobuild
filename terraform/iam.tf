# ---------------------
# EC2 role (SSM)
# ---------------------
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "${var.aws_prefix}-ec2-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.aws_prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# ---------------------
# CodeBuild role & policy
# ---------------------
data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.aws_prefix}-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.aws_prefix}-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "S3AndSSMPermissions"
        Effect = "Allow"
        Action = [
          "s3:*",
          "ssm:SendCommand",
          "ssm:ListCommands",
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations"
        ]
        Resource = ["*"]
      },
      {
        Sid = "LoggingAndCloudWatch"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "cloudwatch:PutMetricData"
        ]
        Resource = ["*"]
      },
      {
        Sid = "EC2Describe"
        Effect = "Allow"
        Action = ["ec2:DescribeInstances", "ec2:DescribeTags"]
        Resource = ["*"]
      },
      {
        Sid = "IAMPassRole"
        Effect = "Allow"
        Action = ["iam:PassRole"]
        Resource = ["*"]
      }
    ]
  })
}

# ---------------------
# CodePipeline role & policy
# ---------------------
data "aws_iam_policy_document" "codepipeline_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.aws_prefix}-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume.json
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.aws_prefix}-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "s3:*",
          "iam:PassRole",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# ---------------------
# Secrets Manager secret (token placeholder)
# ---------------------
resource "aws_secretsmanager_secret" "github_token" {
  name        = var.github_token_secret_name
  description = "GitHub Personal Access Token used by CodePipeline to access GitHub - insert secret value manually after terraform apply"
  recovery_window_in_days = 0
}
