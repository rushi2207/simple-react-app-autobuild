variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "Existing EC2 SSH key pair name (already present in your account)"
  type        = string
  default     = "case-1"
}

variable "github_repo_https" {
  description = "HTTPS URL for your GitHub repo"
  type        = string
  default     = "https://github.com/rushi2207/simple-react-app-autobuild.git"
}

variable "github_owner" {
  description = "GitHub owner (username or org)"
  type        = string
  default     = "rushi2207"
}

variable "github_repo_name" {
  description = "Repository name"
  type        = string
  default     = "simple-react-app-autobuild"
}

variable "github_branch" {
  description = "Branch to build from"
  type        = string
  default     = "main"
}

variable "aws_prefix" {
  description = "Prefix used in naming AWS resources"
  type        = string
  default     = "novops"
}

variable "ec2_tag_value" {
  description = "Tag Name value to identify EC2 instances to target with SSM"
  type        = string
  default     = "react-app-server"
}

# Name of the Secrets Manager secret to hold GitHub token
variable "github_token_secret_name" {
  description = "Secrets Manager secret name that will store the GitHub Personal Access Token"
  type        = string
  default     = "novops-github-token"
}
