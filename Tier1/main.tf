# Private Subnets
resource "aws_subnet" "private_subnets" {
  for_each   = var.private_subnets
  vpc_id     = data.aws_vpc.default.id
  cidr_block = cidrsubnet(data.aws_vpc.default.cidr_block, 8, each.value)

  tags = {
    Terraform = true
  }
}

# Security Groups
resource "aws_security_group" "tier1_sg" {
  name        = "tier1_sg"
  description = "Allow inbound traffic"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    description = "SSH Inbound"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    description = "Global Outbound"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Global Outbound"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Global Outbound"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "tier1_sg"
    Purpose = "tier1_access_sg"
  }
}

# Create EC2 Instance
# resource "aws_instance" "tier1_sg" {
#   ami                         = "ami-0f2eac25772cd4e36"
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.private_subnets["tier1_sg"].id
#   security_groups             = [aws_security_group.tier1_sg.id]
#   associate_public_ip_address = true
#   key_name                    = data.aws_key_pair.pukey.key_name
#   #iam_instance_profile       = "CloudWatchAgentServerPolicy"

#   tags = {
#     Name = "tier1-access"
#   }
# }

# Create EC2 Instance
resource "aws_instance" "tier1_sg" {
  ami                         = "ami-0f2eac25772cd4e36"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnets["tier1_sg"].id
  security_groups             = [aws_security_group.tier1_sg.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.pukey.key_name
  #iam_instance_profile       = "CloudWatchAgentServerPolicy"
  tags {
    Name = "tier1-access"
  }
}
user_data = <#!/bin/bash
sudo -s
yum update -y
sudo amazon-linux-extras install epel -y
yum update -y
yum install wget -y
yum install nginx -y
yum install git -y
service nginx start
rm -rf /etc/nginx/nginx.conf
cd /etc/nginx/
wget https://raw.githubusercontent.com/Zippyops/phpcodelogin/main/nginx.conf
systemctl restart nginx
HEREDOC
}

