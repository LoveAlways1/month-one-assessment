variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "my_ip" {
  description = "102.209.31.129/32"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "db_instance_type" {
  description = "Database instance type"
  default     = "t3.small"
}

variable "key_name" {
  description = "techcorp-key"
  type        = string
}