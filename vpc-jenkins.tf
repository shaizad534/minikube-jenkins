# Create key using awscli 
# aws ec2 create-key-pair --key-name shaz-tst --query 'KeyMaterial' --output text >shaz-tst.pem
# 

#terraform {
#  backend "s3" {
#    bucket = "state-tf-poc"
#    key    = "mini-tf/terraform.tfstate"
#    region = "eu-central-1"
#  }
#}

# Setup our aws provider
provider "aws" {
  region = var.region
}

# Define a vpc
resource "aws_vpc" "vpc_name" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = var.vpc_name
  }
}

# Internet gateway for the public subnet
resource "aws_internet_gateway" "demo_ig" {
  vpc_id = aws_vpc.vpc_name.id
  tags = {
    Name = "demo_ig"
  }
}

# Create Eip for NAT Gateway
resource "aws_eip" "nat-gw-eip" {
  vpc = true
}

# Nat gateway for the private subnet
resource "aws_nat_gateway" "demo_ngw" {
  allocation_id = aws_eip.nat-gw-eip.id
  subnet_id     = aws_subnet.vpc_public_sn.id

  tags = {
    Name = "demo-ngw"
  }
}

# Public subnet
resource "aws_subnet" "vpc_public_sn" {
  vpc_id            = aws_vpc.vpc_name.id
  cidr_block        = var.vpc_public_subnet_1_cidr
  availability_zone = var.pub_availability_zone
  tags = {
    Name = "vpc_public_sn"
  }
}

# Private subnet
resource "aws_subnet" "vpc_private_sn" {
  vpc_id            = aws_vpc.vpc_name.id
  cidr_block        = var.vpc_private_subnet_1_cidr
  availability_zone = var.pub_availability_zone
  tags = {
    Name = "vpc_private_sn"
  }
}

# Routing table for public subnet
resource "aws_route_table" "vpc_public_sn_rt" {
  vpc_id = aws_vpc.vpc_name.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_ig.id
  }
  tags = {
    Name = "vpc_public_sn_rt"
  }
}

# Associate the routing table to public subnet
resource "aws_route_table_association" "vpc_public_sn_rt_assn" {
  subnet_id      = aws_subnet.vpc_public_sn.id
  route_table_id = aws_route_table.vpc_public_sn_rt.id
}

# Routing table for private subnet
resource "aws_route_table" "vpc_private_sn_rt" {
  vpc_id = aws_vpc.vpc_name.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.demo_ngw.id
  }
  tags = {
    Name = "vpc_private_sn_rt"
  }
}

# Associate the routing table to public subnet
resource "aws_route_table_association" "vpc_private_sn_rt_assn" {
  subnet_id      = aws_subnet.vpc_private_sn.id
  route_table_id = aws_route_table.vpc_private_sn_rt.id
}

# Jenkins EC2 resource
resource "aws_instance" "jenkins" {
  ami                         = var.ami_id
  instance_type               = var.instancetype
  key_name                    = "shaz-tst"
  subnet_id                   = aws_subnet.vpc_public_sn.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins.id]

  user_data = file("user-data.sh")
  tags = {
    Name = var.AppName
    Env  = var.Env
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Adding Security Group for our Instance :
resource "aws_security_group" "jenkins" {
  name        = "jenkins-sg"
  description = "Jenkins Security Group"
  vpc_id      = aws_vpc.vpc_name.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.HostIp]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.HostIp]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.PvtIp]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

# minikube EC2 resource
resource "aws_instance" "minikube" {
  ami                         = var.ami_id
  instance_type               = var.instancetype
  key_name                    = "shaz-tst"
  subnet_id                   = aws_subnet.vpc_private_sn.id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.minikube.id]

  user_data = file("minikube-user-data.sh")
  tags = {
    Name = var.mini_name
    Env  = var.Env
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Adding Security Group for our Instance :
resource "aws_security_group" "minikube" {
  name        = "minikube-sg"
  description = "minikube Security Group"
  vpc_id      = aws_vpc.vpc_name.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.HostIp]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.HostIp]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.PvtIp]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
