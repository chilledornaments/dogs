resource "aws_api_gateway_rest_api" "link_retriever" {
  name                         = "dog-api-link-retriever"
  description                  = "API Gateway in front of link-retriever Lambda"
  disable_execute_api_endpoint = true

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_domain_name" "link_retriever" {
  domain_name              = "api.${data.aws_route53_zone.dogs.name}"
  regional_certificate_arn = aws_acm_certificate.api.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "link_retriever_random" {
  parent_id   = aws_api_gateway_rest_api.link_retriever.root_resource_id
  path_part   = "random"
  rest_api_id = aws_api_gateway_rest_api.link_retriever.id
}

resource "aws_api_gateway_method" "link_retriever_get_random" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.link_retriever_api_random.id
  rest_api_id   = aws_api_gateway_rest_api.link_retriever.id
}

resource "aws_api_gateway_integration" "link_retriever_lambda" {
  http_method             = aws_api_gateway_method.link_retriever_get_random.http_method
  resource_id             = aws_api_gateway_resource.link_retriever_api_random.id
  rest_api_id             = aws_api_gateway_rest_api.link_retriever.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.link_retriever.invoke_arn
}

resource "aws_api_gateway_deployment" "link_retriever" {
  rest_api_id = aws_api_gateway_rest_api.link_retriever.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.link_retriever_api_random.id,
      aws_api_gateway_method.link_retriever_get_random.id,
      aws_api_gateway_integration.link_retriever_lambda.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "v1" {
  deployment_id = aws_api_gateway_deployment.link_retriever.id
  rest_api_id   = aws_api_gateway_rest_api.link_retriever.id
  stage_name    = "v1"
}

resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.link_retriever.id
  stage_name  = aws_api_gateway_stage.v1.stage_name
  domain_name = aws_api_gateway_domain_name.link_retriever.domain_name
}
