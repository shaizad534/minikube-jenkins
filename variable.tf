# Variables TF File

variable "region" {
  description = "AWS Region "
  default     = "eu-central-1"
}

variable "ami_id" {
  description = "AMI ID to be used for Instance "
  default     = "ami-043097594a7df80ec"
}

variable "instancetype" {
  description = "Instance Type to be used for Instance "
  default     = "t3.medium"
}

variable "pub_availability_zone" {
  description = "availability zone used for the demo, based on region"
  default     = "eu-central-1a"
}

variable "pri_availability_zone" {
  description = "availability zone used for the demo, based on region"
  default     = "eu-central-1b"
}

variable "HostIp" {
  description = " Host IP to be allowed SSH for"
  default     = "202.65.147.137/32"
}

variable "PvtIp" {
  description = " Host IP to be allowed SSH for"
  default     = "10.126.12.0/24"
}

variable "AppName" {
  description = "Application Name"
  default     = "jenkins-Host"
}

variable "Env" {
  description = "Application Name"
  default     = "Dev"
}

variable "mini_name" {
  description = "Application Name"
  default     = "minikube-Host"
}

########################### demo VPC Config ##################################

variable "vpc_name" {
  description = "VPC for building demos"
  default     = "demo-vpc"
}

variable "vpc_cidr_block" {
  description = "IP addressing for demo Network"
  default     = "10.126.0.0/16"
}

variable "vpc_public_subnet_1_cidr" {
  description = "Public 0.0 CIDR for externally accessible subnet"
  default     = "10.126.1.0/24"
}

variable "vpc_private_subnet_1_cidr" {
  description = "Private CIDR for internally accessible subnet"
  default     = "10.126.12.0/24"
}
