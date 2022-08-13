terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.26"
        }
    }
}

#MAIN API
resource "aws_apigatewayv2_api" "this" {
    count = var.create ? 1 : 0
    name = var.api_name
    protocol_type = "HTTP"
}

#CUSTOM DOMAIN
resource "aws_apigatewayv2_domain_name" "api_domain" {
    count = var.create && var.create_custom_domain && var.custom_domain_name != "" ? 1 : 0
    domain_name = var.custom_domain_name

    domain_name_configuration {
        certificate_arn = var.custom_domain_acm_certificate_arn
        endpoint_type   = "REGIONAL"
        security_policy = "TLS_1_2"
    }
}

#ROUTES - HTTP API has only routes, no resources and methods
resource "aws_apigatewayv2_route" "api_route" {
    for_each = var.create ? var.routes : {}
    api_id = aws_apigatewayv2_api.this[0].id
    route_key = "${each.value["method"]} /${each.value["path"]}"
}

# #ROUTE RESPONSES
# resource "aws_apigatewayv2_route_response" "api_route_response" {
#     for_each = var.create ? var.routes : {}
#     api_id = aws_apigatewayv2_api.this[0].id
#     route_id = aws_apigatewayv2_route.api_route[each.key].id
#     route_response_key = "$default"
# }

#LAMBDA INTEGRATION
resource "aws_apigatewayv2_integration" "api_lambda_integration" {
    for_each = var.create ? var.routes : {}
    api_id = aws_apigatewayv2_api.this[0].id
    integration_type = "AWS_PROXY"

    connection_type = "INTERNET"
    description = ""
    integration_method = each.value["method"]
    integration_uri = each.value["integration"]
}

#INTEGRATION RESPONSES
resource "aws_apigatewayv2_integration_response" "api_integration_response" {
    for_each = var.create ? var.routes : {}
    api_id = aws_apigatewayv2_api.this[0].id

    integration_id = aws_apigatewayv2_integration.api_lambda_integration[each.key].id
    integration_response_key = "/200/"
}

#DEPLOYMENT
resource "aws_apigatewayv2_deployment" "api_deployment" {
    count = var.create ? 1 : 0
    api_id = aws_apigatewayv2_api.this[0].id

    lifecycle {
      create_before_destroy = true
    }
}

#STAGE
resource "aws_apigatewayv2_stage" "api_stage" {
    count = var.create ? 1 : 0
    api_id = aws_apigatewayv2_api.this[0].id
    name = var.stage_name
    deployment_id = aws_apigatewayv2_deployment.api_deployment[0].id
}