output "ec2_public_ip" {
  value = aws_instance.react_app.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.react_app.public_dns
}

output "cicd_s3_bucket" {
  value = aws_s3_bucket.cicd_bucket.bucket
}

output "codebuild_project" {
  value = aws_codebuild_project.react_build.name
}

output "codepipeline_name" {
  value = aws_codepipeline.react_pipeline.name
}

output "secretsmanager_github_secret_name" {
  value = aws_secretsmanager_secret.github_token.name
}
