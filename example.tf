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

resource "aws_security_group" "web_server" {
  name = "web_server"
  
  ingress {
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-08d70e59c07c61a3a"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.web_server.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
}

#==============================================================================
# Database
#==============================================================================

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

resource "aws_security_group" "database" {
  name = "database"
  vpc_id = data.aws_vpc.default.id
  
  ingress {
    from_port = var.port
    to_port = var.port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]    
  }
}

resource "aws_db_instance" "database" {
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
  vpc_security_group_ids = [aws_security_group.database.id]
  publicly_accessible    = true
  # parameter_group_name   = aws_db_parameter_group.example.id
  # option_group_name      = aws_db_option_group.example.id

  tags = {
    Name = var.name
  }
}

#==============================================================================
# API
#==============================================================================

data "archive_file" "lambda" {
  source_file = "toRomanNumeral.js"
  type = "zip"
  output_path = "toRomanNumeral.zip"
}

resource "aws_lambda_function" "to-roman-numberal-js" {
  filename = "toRomanNumeral.zip"
  function_name = "ToRomanNumberalJs"
  handler = "toRomanNumeral.handler"
  role = "${aws_iam_role.lambda-role.arn}"
  runtime = "nodejs12.x"
  source_code_hash = "${filebase64("${data.archive_file.lambda.output_path}")}"
}

resource "aws_lambda_permission" "allow_api_gateway" {
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.to-roman-numberal-js.arn}"
  statement_id = "AllowExecutionFromApiGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.roman-numeral-api.execution_arn}/*/*/*"
}

resource "aws_iam_role" "lambda-role" {
  name = "iam-lambda-role"
  assume_role_policy = "${file("lambdaRole.json")}"
}

resource "aws_api_gateway_rest_api" "roman-numeral-api" {
  name = "RomanNumeralAPI"
  description = "A Prototype REST API for Converting Integers to Roman Numerals"
}

resource "aws_api_gateway_resource" "roman-numeral-api-resource" {
  rest_api_id = "${aws_api_gateway_rest_api.roman-numeral-api.id}"
  parent_id = "${aws_api_gateway_rest_api.roman-numeral-api.root_resource_id}"

  path_part = "roman-numeral"
}

resource "aws_api_gateway_resource" "integer-api-resource" {
  rest_api_id = "${aws_api_gateway_rest_api.roman-numeral-api.id}"
  parent_id = "${aws_api_gateway_resource.roman-numeral-api-resource.id}"

  path_part = "{integer}"
}

resource "aws_api_gateway_method" "integer-to-roman-numeral-method" {
  rest_api_id = "${aws_api_gateway_rest_api.roman-numeral-api.id}"
  resource_id = "${aws_api_gateway_resource.integer-api-resource.id}"

  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda-api-integration" {
  rest_api_id = "${aws_api_gateway_rest_api.roman-numeral-api.id}"
  resource_id = "${aws_api_gateway_resource.integer-api-resource.id}"

  http_method = "${aws_api_gateway_method.integer-to-roman-numeral-method.http_method}"
  type = "AWS"
  uri = "${aws_lambda_function.to-roman-numberal-js.invoke_arn}"
  integration_http_method = "POST"
  request_templates = {
    "application/json" = "${file("request.vm")}"
  }
}

resource "aws_api_gateway_method_response" "lambda-api-method-response" {
  rest_api_id = "${aws_api_gateway_rest_api.roman-numeral-api.id}"
  resource_id = "${aws_api_gateway_resource.integer-api-resource.id}"
  http_method = "${aws_api_gateway_method.integer-to-roman-numeral-method.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "lambda-api-integration-response" {
  rest_api_id = "${aws_api_gateway_rest_api.roman-numeral-api.id}"
  resource_id = "${aws_api_gateway_resource.integer-api-resource.id}"
  http_method = "${aws_api_gateway_method.integer-to-roman-numeral-method.http_method}"

  status_code = "${aws_api_gateway_method_response.lambda-api-method-response.status_code}"
  response_templates = {
    "application/json" = "${file("response.vm")}"
  }

  depends_on = [
    "aws_api_gateway_integration.lambda-api-integration"
  ]
}

resource "aws_api_gateway_deployment" "roman-numeral-api-dev-deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.roman-numeral-api.id}"

  stage_name = "dev"

  depends_on = [
    "aws_api_gateway_integration.lambda-api-integration",
    "aws_api_gateway_integration_response.lambda-api-integration-response"
  ]
}


#==============================================================================
# Variables
#==============================================================================

variable "server_port" {
  description = "HTTP requests port"
  type = number
  default = 8080
}

variable "username" {
  description = "Master username of the DB"
  type        = string
  default     = "postgres"
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
  value = aws_instance.web_server.public_ip
  description = "Public server IP"
}

output "database_endpoint" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.database.endpoint
}

output "api_url" {
  value = "${aws_api_gateway_deployment.roman-numeral-api-dev-deployment.invoke_url}"
}
