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

# Nova política para acessar o bucket S3
resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "LambdaS3Policy"
  description = "Policy to allow Lambda to access S3 bucket"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::meu-upload-bucket-daniel-19092024",
          "arn:aws:s3:::meu-upload-bucket-daniel-19092024/*"
        ]
      }
    ]
  })
}

# Anexa a política S3 à função Lambda
resource "aws_iam_role_policy_attachment" "attach_lambda_s3_policy" {
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
  role       = aws_iam_role.lambda_exec.name
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

# Permissões para a API Gateway invocar as Lambdas
resource "aws_lambda_permission" "upload_permission" {
  statement_id  = "AllowExecutionFromAPIGatewayUpload"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/upload"  # Atualizado para API HTTP
}

resource "aws_lambda_permission" "list_permission" {
  statement_id  = "AllowExecutionFromAPIGatewayList"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/list-files"  # Atualizado para API HTTP
}