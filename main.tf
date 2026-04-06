terraform { 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.39.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "techcorp_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "techcorp-vpc"
  }
}

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "techcorp-public-subnet-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "techcorp-public-subnet-2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "techcorp-private-subnet-1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "techcorp-private-subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.techcorp_vpc.id

  tags = {
    Name = "techcorp-igw"
  }
}

resource "aws_eip" "nat_eip1" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat_eip1.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "techcorp-nat-1"
  }
}

resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.public2.id

  tags = {
    Name = "techcorp-nat-2"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.techcorp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "techcorp-public-rt"
  }
}

resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public2_assoc" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt1" {
  vpc_id = aws_vpc.techcorp_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat1.id
  }

  tags = {
    Name = "techcorp-private-rt-1"
  }
}

resource "aws_route_table" "private_rt2" {
  vpc_id = aws_vpc.techcorp_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat2.id
  }

  tags = {
    Name = "techcorp-private-rt-2"
  }
}

resource "aws_route_table_association" "private1_assoc" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private_rt1.id
}

resource "aws_route_table_association" "private2_assoc" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private_rt2.id
}

resource "aws_security_group" "bastion_sg" {
  name   = "techcorp-bastion-sg"
  vpc_id = aws_vpc.techcorp_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_sg" {
  name   = "techcorp-web-sg"
  vpc_id = aws_vpc.techcorp_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  name   = "techcorp-db-sg"
  vpc_id = aws_vpc.techcorp_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public1.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  associate_public_ip_address = true

  tags = {
    Name = "techcorp-bastion"
  }
}

resource "aws_instance" "web1" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private1.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = file("user_data/web_server_setup.sh")

  tags = {
    Name = "techcorp-web-1"
  }
}

resource "aws_instance" "web2" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private2.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = file("user_data/web_server_setup.sh")

  tags = {
    Name = "techcorp-web-2"
  }
}

resource "aws_instance" "db" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = var.db_instance_type
  subnet_id     = aws_subnet.private1.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.db_sg.id]

  user_data = file("user_data/db_server_setup.sh")

  tags = {
    Name = "techcorp-db"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "techcorp-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.techcorp_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "web1_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web2_attach" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

resource "aws_lb" "alb" {
  name               = "techcorp-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [
    aws_subnet.public1.id,
    aws_subnet.public2.id
  ]

 security_groups = [aws_security_group.alb_sg.id]

  tags = {
    Name = "techcorp-alb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_security_group" "alb_sg" {
  name   = "techcorp-alb-sg"
  vpc_id = aws_vpc.techcorp_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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