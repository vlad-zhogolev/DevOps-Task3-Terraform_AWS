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
# data "aws_vpc" "default" {
#   default = true
# }

# data "aws_subnet_ids" "all" {
#   vpc_id = data.aws_vpc.default.id
# }

# resource "aws_db_subnet_group" "example" {
#   name       = var.name
#   subnet_ids = data.aws_subnet_ids.all.ids

#   tags = {
#     Name = var.name
#   }
# }

# resource "aws_security_group" "db_instance" {
#   name   = var.name
#   vpc_id = data.aws_vpc.default.id
# }

# resource "aws_security_group" "allow_db_access" {
#   name = "allow_db_access"
  
#   ingress {
#     from_port = var.port
#     to_port = var.port
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_db_instance" "example_database" {
#   identifier             = var.name
#   engine                 = var.engine_name
#   engine_version         = var.engine_version
#   port                   = var.port
#   name                   = var.database_name
#   username               = var.username
#   password               = var.password
#   instance_class         = "db.t2.micro"
#   allocated_storage      = var.allocated_storage
#   skip_final_snapshot    = true
#   license_model          = var.license_model
#   db_subnet_group_name   = aws_db_subnet_group.example.id
#   vpc_security_group_ids = [aws_security_group.allow_db_access.id]
#   publicly_accessible    = true
#   # parameter_group_name   = aws_db_parameter_group.example.id
#   # option_group_name      = aws_db_option_group.example.id

#   tags = {
#     Name = var.name
#   }
# }

# resource "aws_api_gateway_rest_api" "MyDemoAPI" {
#   name        = "MyDemoAPI"
#   description = "This is my API for demonstration purposes"
# }

# resource "aws_api_gateway_resource" "MyDemoResource" {
#   rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
#   parent_id   = aws_api_gateway_rest_api.MyDemoAPI.root_resource_id
#   path_part   = "mydemoresource"
# }

# resource "aws_api_gateway_method" "MyDemoMethod" {
#   rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
#   resource_id   = aws_api_gateway_resource.MyDemoResource.id
#   http_method   = "GET"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "MyDemoIntegration" {
#   rest_api_id          = aws_api_gateway_rest_api.MyDemoAPI.id
#   resource_id          = aws_api_gateway_resource.MyDemoResource.id
#   http_method          = aws_api_gateway_method.MyDemoMethod.http_method
#   type                 = "MOCK"
#   # cache_key_parameters = ["method.request.path.param"]
#   cache_namespace      = "foobar"
#   timeout_milliseconds = 29000

#   request_parameters = {
#     "integration.request.header.X-Authorization" = "'static'"
#   }

#   # Transforms the incoming XML request to JSON
#   request_templates = {
    
#     "application/xml" = <<EOF
# {
#    "body" : $input.json('$')
# }
# EOF
#   }
# }

# resource "aws_api_gateway_rest_api" "api" {
#  name = "api-gateway"
#  description = “Proxy to handle requests to our API”
# }

# resource "aws_api_gateway_resource" "resource" {
#   rest_api_id = "${aws_api_gateway_rest_api.api.id}"
#   parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
#   path_part   = "{proxy+}"
# }
# resource "aws_api_gateway_method" "method" {
#   rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
#   resource_id   = "${aws_api_gateway_resource.resource.id}"
#   http_method   = "ANY"
#   authorization = "NONE"
#   request_parameters = {
#     "method.request.path.proxy" = true
#   }
# }
# resource "aws_api_gateway_integration" "integration" {
#   rest_api_id = "${aws_api_gateway_rest_api.api.id}"
#   resource_id = "${aws_api_gateway_resource.resource.id}"
#   http_method = "${aws_api_gateway_method.method.http_method}"
#   integration_http_method = "ANY"
#   type                    = "HTTP_PROXY"
#   uri                     = "http://your.domain.com/{proxy}"
 
#   request_parameters =  {
#     "integration.request.path.proxy" = "method.request.path.proxy"
#   }
# }

# resource "aws_api_gateway_rest_api" "MyDemoAPI" {
#   name        = "MyDemoAPI"
#   description = "This is my API for demonstration purposes"
# }

# resource "aws_api_gateway_resource" "MyDemoResource" {
#   rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
#   parent_id   = aws_api_gateway_rest_api.MyDemoAPI.root_resource_id
#   path_part   = "mydemoresource"
# }

# resource "aws_api_gateway_method" "MyDemoMethod" {
#   rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
#   resource_id   = aws_api_gateway_resource.MyDemoResource.id
#   http_method   = "GET"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "MyDemoIntegration" {
#   rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
#   resource_id = aws_api_gateway_resource.MyDemoResource.id
#   http_method = aws_api_gateway_method.MyDemoMethod.http_method
#   type        = "MOCK"  
# }

# resource "aws_api_gateway_method_response" "response_200" {
#   rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
#   resource_id = aws_api_gateway_resource.MyDemoResource.id
#   http_method = aws_api_gateway_method.MyDemoMethod.http_method
#   status_code = "200"
# }

# resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
#   rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
#   resource_id = aws_api_gateway_resource.MyDemoResource.id
#   http_method = aws_api_gateway_method.MyDemoMethod.http_method
#   status_code = aws_api_gateway_method_response.response_200.status_code

#   # Transforms the backend JSON response to XML
#   response_templates = {
#     "application/xml" = <<EOF
# #set($inputRoot = $input.path('$'))
# <?xml version="1.0" encoding="UTF-8"?>
# <message>
#     $inputRoot.body
# </message>
# EOF
#   }
# }

# A data source containing the lambda function
data "archive_file" "lambda" {
  source_file = "toRomanNumeral.js"
  type = "zip"
  output_path = "toRomanNumeral.zip"
}

resource "aws_lambda_function" "to-roman-numberal-js" {
  # The local file to use as the lambda function.  A popular alternative is to keep the lambda function
  # source code in an S3 bucket.
  filename = "toRomanNumeral.zip"

  # A unique name to give the lambda function.
  function_name = "ToRomanNumberalJs"

  # The entrypoint to the lambda function in the source code.  The format is <file-name>.<property-name>
  handler = "toRomanNumeral.handler"

  # IAM (Identity and Access Management) policy for the lambda function.
  role = "${aws_iam_role.lambda-role.arn}"

  # Use Node.js for this lambda function.
  runtime = "nodejs12.x"

  # The source code hash is used by Terraform to detect whether the source code of the lambda function
  # has changed.  If it changed, Terraform will re-upload the lambda function.
  source_code_hash = "${filebase64("${data.archive_file.lambda.output_path}")}"
}

# Set permissions on the lambda function, allowing API Gateway to invoke the function
resource "aws_lambda_permission" "allow_api_gateway" {
  # The action this permission allows is to invoke the function
  action = "lambda:InvokeFunction"

  # The name of the lambda function to attach this permission to
  function_name = "${aws_lambda_function.to-roman-numberal-js.arn}"

  # An optional identifier for the permission statement
  statement_id = "AllowExecutionFromApiGateway"

  # The item that is getting this lambda permission
  principal = "apigateway.amazonaws.com"

  # /*/*/* sets this permission for all stages, methods, and resource paths in API Gateway to the lambda
  # function. - https://bit.ly/2NbT5V5
  source_arn = "${aws_api_gateway_rest_api.roman-numeral-api.execution_arn}/*/*/*"
}

# Create an IAM role for the lambda function
resource "aws_iam_role" "lambda-role" {
  name = "iam-lambda-role"
  assume_role_policy = "${file("lambdaRole.json")}"
}

# Declare a new API Gateway REST API
resource "aws_api_gateway_rest_api" "roman-numeral-api" {
  # The name of the REST API
  name = "RomanNumeralAPI"

  # An optional description of the REST API
  description = "A Prototype REST API for Converting Integers to Roman Numerals"
}

# Create an API Gateway resource, which is a certain path inside the REST API
resource "aws_api_gateway_resource" "roman-numeral-api-resource" {
  # The id of the associated REST API and parent API resource are required
  rest_api_id = "${aws_api_gateway_rest_api.roman-numeral-api.id}"
  parent_id = "${aws_api_gateway_rest_api.roman-numeral-api.root_resource_id}"

  # The last segment of the URL path for this API resource
  path_part = "roman-numeral"
}

resource "aws_api_gateway_resource" "integer-api-resource" {
  rest_api_id = "${aws_api_gateway_rest_api.roman-numeral-api.id}"
  parent_id = "${aws_api_gateway_resource.roman-numeral-api-resource.id}"

  path_part = "{integer}"
}

# Provide an HTTP method to a API Gateway resource (REST endpoint)
resource "aws_api_gateway_method" "integer-to-roman-numeral-method" {
  # The ID of the REST API and the resource at which the API is invoked
  rest_api_id = "${aws_api_gateway_rest_api.roman-numeral-api.id}"
  resource_id = "${aws_api_gateway_resource.integer-api-resource.id}"

  # The verb of the HTTP request
  http_method = "GET"

  # Whether any authentication is needed to call this endpoint
  authorization = "NONE"
}

# Integrate API Gateway REST API with a Lambda function
resource "aws_api_gateway_integration" "lambda-api-integration" {
  # The ID of the REST API and the endpoint at which to integrate a Lambda function
  rest_api_id = "${aws_api_gateway_rest_api.roman-numeral-api.id}"
  resource_id = "${aws_api_gateway_resource.integer-api-resource.id}"

  # The HTTP method to integrate with the Lambda function
  http_method = "${aws_api_gateway_method.integer-to-roman-numeral-method.http_method}"

  # AWS is used for Lambda proxy integration when you want to use a Velocity template
  type = "AWS"

  # The URI at which the API is invoked
  uri = "${aws_lambda_function.to-roman-numberal-js.invoke_arn}"

  # Lambda functions can only be invoked via HTTP POST - https://amzn.to/2owMYNh
  integration_http_method = "POST"

  # Configure the Velocity request template for the application/json MIME type
  request_templates = {
    "application/json" = "${file("request.vm")}"
  }
}

# Create an HTTP method response for the aws lambda integration
resource "aws_api_gateway_method_response" "lambda-api-method-response" {
  rest_api_id = "${aws_api_gateway_rest_api.roman-numeral-api.id}"
  resource_id = "${aws_api_gateway_resource.integer-api-resource.id}"
  http_method = "${aws_api_gateway_method.integer-to-roman-numeral-method.http_method}"
  status_code = "200"
}

# Configure the API Gateway and Lambda functions response
resource "aws_api_gateway_integration_response" "lambda-api-integration-response" {
  rest_api_id = "${aws_api_gateway_rest_api.roman-numeral-api.id}"
  resource_id = "${aws_api_gateway_resource.integer-api-resource.id}"
  http_method = "${aws_api_gateway_method.integer-to-roman-numeral-method.http_method}"

  status_code = "${aws_api_gateway_method_response.lambda-api-method-response.status_code}"

  # Configure the Velocity response template for the application/json MIME type
  response_templates = {
    "application/json" = "${file("response.vm")}"
  }

  # Remove race condition where the integration response is built before the lambda integration
  depends_on = [
    "aws_api_gateway_integration.lambda-api-integration"
  ]
}

# Create a new API Gateway deployment
resource "aws_api_gateway_deployment" "roman-numeral-api-dev-deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.roman-numeral-api.id}"

  # development stage
  stage_name = "dev"

  # Remove race conditions - deployment should always occur after lambda integration
  depends_on = [
    "aws_api_gateway_integration.lambda-api-integration",
    "aws_api_gateway_integration_response.lambda-api-integration-response"
  ]
}

# URL to invoke the API
output "url" {
  value = "${aws_api_gateway_deployment.roman-numeral-api-dev-deployment.invoke_url}"
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

# output "this_db_instance_address" {
#   description = "The address of the RDS instance"
#   value       = aws_db_instance.example_database.address
# }

# output "this_db_instance_endpoint" {
#   description = "The address of the RDS instance"
#   value       = aws_db_instance.example_database.endpoint
# }