resource "aws_iam_role" "lambda_exec" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "upload_lambda" {
  function_name = "uploadLambda"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.upload_bucket.bucket
    }
  }

  filename         = "../backend/upload/lambda_upload.zip"
  source_code_hash = filebase64sha256("../backend/upload/lambda_upload.zip")
}

resource "aws_lambda_function" "list_lambda" {
  function_name = "listLambda"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.upload_bucket.bucket
    }
  }

  filename         = "../backend/list/lambda_list.zip"
  source_code_hash = filebase64sha256("../backend/list/lambda_list.zip")
}

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

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.upload_integration,
    aws_api_gateway_integration.list_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}
