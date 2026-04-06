output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.techcorp_vpc.id
}

output "alb_dns_name" {
  description = "Load Balancer DNS"
  value       = aws_lb.alb.dns_name
}

output "bastion_public_ip" {
  description = "Bastion Public IP"
  value       = aws_instance.bastion.public_ip
}