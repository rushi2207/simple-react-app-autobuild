resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "cicd_bucket" {
  bucket = "${var.aws_prefix}-react-cicd-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_acl" "cicd_bucket_acl" {
  bucket = aws_s3_bucket.cicd_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "cicd_versioning" {
  bucket = aws_s3_bucket.cicd_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cicd_lifecycle" {
  bucket = aws_s3_bucket.cicd_bucket.id

  rule {
    id     = "cleanup"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

# CodeBuild project
resource "aws_codebuild_project" "react_build" {
  name          = "${var.aws_prefix}-react-build"
  description   = "Builds React app and uploads artifact"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 60

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "S3_BUCKET"
      value = aws_s3_bucket.cicd_bucket.bucket
    }
    environment_variable {
      name  = "TARGET_TAG_KEY"
      value = "Name"
    }
    environment_variable {
      name  = "TARGET_TAG_VALUE"
      value = var.ec2_tag_value
    }
  }

  source {
    type      = "GITHUB"
    location  = var.github_repo_https
    buildspec = "buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.aws_prefix}-react-build"
      stream_name = "build-log"
      status      = "ENABLED"
    }
  }
}

# CodePipeline
resource "aws_codepipeline" "react_pipeline" {
  name     = "${var.aws_prefix}-react-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.cicd_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo_name
        Branch     = var.github_branch
        OAuthToken = aws_secretsmanager_secret.github_token.arn
      }
    }
  }

  stage {
    name = "Build"
    action {
      name            = "CodeBuild"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]
      configuration = {
        ProjectName = aws_codebuild_project.react_build.name
      }
    }
  }
}
