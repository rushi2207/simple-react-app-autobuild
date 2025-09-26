# Get a recent Ubuntu AMI for the region (more portable than a hardcoded AMI)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "react_sg" {
  name        = "${var.aws_prefix}-react-sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.aws_prefix}-react-sg"
  }
}

resource "aws_instance" "react_app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.react_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  # IMPORTANT: we clone the repo at boot and build the app once
  user_data = <<-EOF
    #!/bin/bash
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

    apt-get update -y
    apt-get install -y curl git nginx unzip

    # Install Node.js LTS
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y nodejs build-essential

    # Clone repo (this uses the HTTPS public repo URL you provided)
    rm -rf /home/ubuntu/reactapp
    git clone ${var.github_repo_https} /home/ubuntu/reactapp || true
    cd /home/ubuntu/reactapp || exit 0

    npm ci || npm install
    npm run build || true

    # Copy build files to nginx root if build exists
    if [ -d "/home/ubuntu/reactapp/build" ]; then
      rm -rf /var/www/html/*
      cp -r /home/ubuntu/reactapp/build/* /var/www/html/
      chown -R www-data:www-data /var/www/html
      chmod -R 755 /var/www/html
    fi

    systemctl enable nginx
    systemctl restart nginx || true
  EOF

  tags = {
    Name = var.ec2_tag_value
  }
}
