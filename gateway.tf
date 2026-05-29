
############################################
# API GATEWAY (HTTP API)
############################################
resource "aws_apigatewayv2_api" "api" {
  name          = "eks-api"
  protocol_type = "HTTP"
}

############################################
# SECURITY GROUP FOR VPC LINK
############################################
resource "aws_security_group" "vpclink_sg" {
  name   = "vpclink-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# VPC LINK
############################################
resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "eks-vpc-link"
  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpclink_sg.id]
}

############################################
# GET KUBERNETES CREATED NLB
############################################
data "aws_lb" "nlb" {
  tags = {
    "kubernetes.io/service-name" = "default/httpd-server"
  }
}

############################################
# API GATEWAY INTEGRATION (CORRECT)
############################################
resource "aws_apigatewayv2_integration" "integration" {
  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"

  connection_type = "VPC_LINK"
  connection_id   = aws_apigatewayv2_vpc_link.vpc_link.id

  # IMPORTANT: use NLB DNS, NOT listener ARN
  integration_uri = "http://${data.aws_lb.nlb.dns_name}"
}

############################################
# ROUTE
############################################
resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

############################################
# STAGE
############################################
resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

############################################
# OUTPUT
############################################
output "api_gateway_url" {
  value = aws_apigatewayv2_api.api.api_endpoint
}
