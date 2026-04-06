TechCorp Terraform Infrastructure Deployment
Overview
This project provisions a highly available web application infrastructure on AWS using Terraform.

Architecture
•	VPC: techcorp-vpc (10.0.0.0/16)
•	Public Subnets (2 AZs)
•	Private Subnets (2 AZs)
•	Internet Gateway & NAT Gateways
•	Bastion Host (public subnet)
•	Web Servers (2 instances in private subnets)
•	Database Server (PostgreSQL in private subnet)
•	Application Load Balancer (techcorp-alb)

Prerequisites
•	AWS Account
•	Terraform installed
•	AWS CLI configured
•	Key Pair created in AWS (techcorp-key)

Deployment Steps
1.	Navigate to project directory: cd terraform-assessment
2.	Initialize Terraform: terraform init
3.	Review execution plan: terraform plan
4.	Apply configuration: terraform apply

Access Application
Get the Load Balancer DNS:
terraform output alb_dns_name
Mine:
http://techcorp-alb-151826721.us-east-1.elb.amazonaws.com/

SSH Access
Connect to Bastion Host:
ssh -i techcorp-key.pem ec2-user@<bastion_public_ip>
From Bastion → Web Server:
ssh ec2-user@
From Bastion → Database Server:
ssh ec2-user@

PostgreSQL Access
On the DB server:
sudo -i -u postgres
psql

Cleanup (Destroy Infrastructure)
To avoid unnecessary AWS charges, destroy all resources:
terraform destroy
Type:
yes

Outputs
•	VPC ID
•	Load Balancer DNS Name
•	Bastion Public IP

Evidence
All screenshots are included in the evidence/ folder.

