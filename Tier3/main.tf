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
resource "aws_security_group" "tier3_sg" {
  name        = "tier3_sg"
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
    description = "MySQL Inbound"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description = "SQL Inbound"
    from_port   = 1433
    to_port     = 1433
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
    Name    = "tier3_sg"
    Purpose = "tier3_core_sg"
  }
}

# Create EC2 Instance
resource "aws_instance" "tier3_sg" {
  ami                         = "ami-0f2eac25772cd4e36"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnets["tier3_sg"].id
  security_groups             = [aws_security_group.tier3_sg.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.pukey.key_name
  #iam_instance_profile       = "CloudWatchAgentServerPolicy"

  tags = {
    Name = "tier3-core"
  }
}