resource "aws_apigatewayv2_api" "api" {
  name          = "file-upload-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "upload_integration" {
  api_id               = aws_apigatewayv2_api.api.id
  integration_type     = "AWS_PROXY"
  integration_uri      = aws_lambda_function.upload_lambda.invoke_arn
  integration_method   = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "upload_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /upload"
  target    = "integrations/${aws_apigatewayv2_integration.upload_integration.id}"
}

resource "aws_apigatewayv2_integration" "list_integration" {
  api_id               = aws_apigatewayv2_api.api.id
  integration_type     = "AWS_PROXY"
  integration_uri      = aws_lambda_function.list_lambda.invoke_arn
  integration_method   = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "list_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /list-files"
  target    = "integrations/${aws_apigatewayv2_integration.list_integration.id}"
}

resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id = aws_apigatewayv2_api.api.id

  depends_on = [
    aws_apigatewayv2_route.upload_route,
    aws_apigatewayv2_route.list_route
  ]
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id     = aws_apigatewayv2_api.api.id
  name = "prod"
  deployment_id = aws_apigatewayv2_deployment.api_deployment.id
}
