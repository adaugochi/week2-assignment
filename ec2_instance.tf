# Create a VPC and subnet for our instances
resource "aws_vpc" "tech4dev" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "tech4dev" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.tech4dev.id
  availability_zone = "us-east-1a"
}

# Create a security group for our instances
resource "aws_security_group" "tech4dev" {
  name        = "tech4dev-sg"
  description = "Allow inbound traffic on port 22"
  vpc_id      = aws_vpc.tech4dev.id

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
}

# Create an EC2 instance profile
resource "aws_iam_instance_profile" "tech4devx" {
  name = "tech4devx-profile"
  role = aws_iam_role.tech4dev.name
}

# Create an IAM role for our instances
resource "aws_iam_role" "tech4dev" {
  name = "tech4dev-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })
}

# Create two EC2 instances
resource "aws_instance" "tech4dev1" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.tech4dev.id]
  subnet_id              = aws_subnet.tech4dev.id
  iam_instance_profile   = aws_iam_instance_profile.tech4devx.name

  key_name = "my_key_pair"

  tags = {
    Name        = "tech4dev1"
    Environment = "dev"
    Class       = "web"
    Usage       = "demo"
  }

  user_data = <<-EOF
    #!/bin/bash
    # Install prerequisites
    sudo apt-get update -y
    sudo apt-get install -y curl apt-transport-https software-properties-common
    
    # Set up Datadog repository and install the agent
    DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=var.datadog_api_key DD_SITE="datadoghq.com"
    bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

    # Start the agent
    systemctl start datadog-agent
    systemctl enable datadog-agent
  EOF
}


