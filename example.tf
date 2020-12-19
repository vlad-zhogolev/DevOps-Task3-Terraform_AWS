terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_instance" "example_web_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.asg_ec2_example.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
}

resource "aws_security_group" "asg_ec2_example" {
  name = "asg_ec2_example"
  
  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# DB instance
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_db_subnet_group" "example" {
  name       = var.name
  subnet_ids = data.aws_subnet_ids.all.ids

  tags = {
    Name = var.name
  }
}

resource "aws_security_group" "db_instance" {
  name   = var.name
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_db_access" {
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  security_group_id = aws_security_group.db_instance.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_db_instance" "example_database" {
  identifier             = var.name
  engine                 = var.engine_name
  engine_version         = var.engine_version
  port                   = var.port
  name                   = var.database_name
  username               = var.username
  password               = var.password
  instance_class         = "db.t2.micro"
  allocated_storage      = var.allocated_storage
  skip_final_snapshot    = true
  license_model          = var.license_model
  db_subnet_group_name   = aws_db_subnet_group.example.id
  vpc_security_group_ids = [aws_security_group.db_instance.id]
  publicly_accessible    = true
  # parameter_group_name   = aws_db_parameter_group.example.id
  # option_group_name      = aws_db_option_group.example.id

  tags = {
    Name = var.name
  }
}


# Variables

variable "server_port" {
  description = "HTTP requests port"
  type = number
  default = 8080
}

variable "username" {
  description = "Master username of the DB"
  type        = string
  default     = "root"
}

variable "password" {
  description = "Master password of the DB"
  type        = string
  default     = "StarWars1"
}

variable "database_name" {
  description = "Name of the database to be created"
  type        = string
  default     = "my_database"
}

variable "name" {
  description = "Name of the database"
  type        = string
  default     = "terratest-example"
}

variable "engine_name" {
  description = "Name of the database engine"
  type        = string
  default     = "postgres"
}

variable "port" {
  description = "Port which the database should run on"
  type        = number
  default     = 5432
}

variable "major_engine_version" {
  description = "MAJOR.MINOR version of the DB engine"
  type        = string
  default     = "11.5"
}

variable "engine_version" {
  description = "Version of the database to be launched"
  default     = "11.5"
  type        = string
}

variable "allocated_storage" {
  description = "Disk space to be allocated to the DB instance"
  type        = number
  default     = 5
}

variable "license_model" {
  description = "License model of the DB instance"
  type        = string
  default     = "postgresql-license"
}

output "web_server_public_ip" {
  value = aws_instance.example_web_server.public_ip
  description = "Public server IP"
}

output "this_db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.example_database.address
}

output "this_db_instance_endpoint" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.example_database.endpoint
}