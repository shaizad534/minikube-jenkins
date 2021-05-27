# Outputs.tf
output "jenkins_instance_id" {
  description = " Instance ID of the instance"
  value       = aws_instance.jenkins.id
}

output "jenkins_instance_IP" {
  description = " Public IP of the instance"
  value       = aws_instance.jenkins.public_ip
}

output "minikube_instance_id" {
  description = " Instance ID of the instance"
  value       = aws_instance.minikube.id
}

output "minikube_instance_IP" {
  description = " Public IP of the instance"
  value       = aws_instance.minikube.private_ip
}

output "vpc_id" {
  value = aws_vpc.vpc_name.id
}

output "vpc_public_sn_id" {
  value = aws_subnet.vpc_public_sn.id
}

output "vpc_private_sn_id" {
  value = aws_subnet.vpc_private_sn.id
}

