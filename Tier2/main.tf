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
resource "aws_security_group" "tier2_sg" {
  name        = "tier2_sg"
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
    Name    = "tier2_sg"
    Purpose = "tier2_distribution_sg"
  }
}

# Create EC2 Instance
resource "aws_instance" "tier2_sg" {
  ami                         = "ami-0f2eac25772cd4e36"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnets["tier2_sg"].id
  security_groups             = [aws_security_group.tier2_sg.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.pukey.key_name
  #iam_instance_profile       = "CloudWatchAgentServerPolicy"

  tags = {
    Name = "tier2-distribution1"
  }
}

# Create EC2 Instance
resource "aws_instance" "tier2_sg" {
  ami                         = "ami-0f2eac25772cd4e36"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnets["tier2_sg"].id
  security_groups             = [aws_security_group.tier2_sg.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.pukey.key_name
  #iam_instance_profile       = "CloudWatchAgentServerPolicy"

  tags {
    Name = "tier2-distribution2"
  }
}
user_data = <
#!/bin/bash
sudo -s
yum update -y
sudo amazon-linux-extras install epel -y
sudo yum update -y
sudo amazon-linux-extras install -y php7.2
sudo yum install httpd -y
service start httpd
yum install git -y
cd /var/www/html/
git clone https://github.com/Zippyops/phpcodelogin.git
cd phpcodelogin/
mv * /var/www/html/
yum install wget -y
yum install mysql -y
yum install mysql-server -y
service mysqld restart
systemctl restart httpd
cd /var/www/html/

mysql -h wpdb.cdy9kerizbgn.ap-southeast-1.rds.amazonaws.com -u zippyops -pmypassword -D wordpress_db < table.sql

HEREDOC
}