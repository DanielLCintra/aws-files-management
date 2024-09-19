resource "aws_api_gateway_rest_api" "api" {
  name = "file-upload-api"
}

resource "aws_api_gateway_resource" "upload_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "upload"
}

resource "aws_api_gateway_method" "upload_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.upload_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "upload_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.upload_resource.id
  http_method = aws_api_gateway_method.upload_method.http_method
  integration_http_method = "POST"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.upload_lambda.invoke_arn
}

# Método OPTIONS para upload
resource "aws_api_gateway_method" "upload_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.upload_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Integração OPTIONS para upload
resource "aws_api_gateway_integration" "upload_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.upload_resource.id
  http_method = aws_api_gateway_method.upload_options_method.http_method
  integration_http_method = "OPTIONS"
  type        = "MOCK"
}

resource "aws_api_gateway_resource" "list_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "list-files"
}

resource "aws_api_gateway_method" "list_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.list_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "list_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.list_resource.id
  http_method = aws_api_gateway_method.list_method.http_method
  integration_http_method = "GET"
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.list_lambda.invoke_arn
}

# Método OPTIONS para list
resource "aws_api_gateway_method" "list_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.list_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Integração OPTIONS para list
resource "aws_api_gateway_integration" "list_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.list_resource.id
  http_method = aws_api_gateway_method.list_options_method.http_method
  integration_http_method = "OPTIONS"
  type        = "MOCK"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.upload_integration,
    aws_api_gateway_integration.list_integration,
    aws_api_gateway_method.upload_method,
    aws_api_gateway_method.list_method,
    aws_api_gateway_method.upload_options_method,
    aws_api_gateway_method.list_options_method
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}