provider "aws" {
  region = var.aws_region
}

# 1. S3 Buckets
resource "aws_s3_bucket" "uploads" {
  bucket = "gcp-image-pipeline-uploads-sai"
}

resource "aws_s3_bucket" "processed" {
  bucket = "gcp-image-pipeline-processed-sai"
}

# 2. SNS Topic
resource "aws_sns_topic" "updates" {
  name = "image-updates-topic"
}

# 3. IAM Role & Policy
resource "aws_iam_role" "lambda_role" {
  name = "image_processor_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:PutObject"],
        Effect   = "Allow",
        Resource = ["${aws_s3_bucket.uploads.arn}/*", "${aws_s3_bucket.processed.arn}/*"]
      },
      {
        Action   = ["sns:Publish"],
        Effect   = "Allow",
        Resource = aws_sns_topic.updates.arn
      },
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# 4. Lambda Function (Updated with Hash)
resource "aws_lambda_function" "processor" {
  filename         = "../functions/image_processor.zip" 
  function_name    = "image_processor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "image_processor.lambda_handler"
  runtime          = "python3.9"
  timeout          = 30
  
  source_code_hash = filebase64sha256("../functions/image_processor.zip")

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.updates.arn
    }
  }
}

# 5. S3 Trigger
resource "aws_lambda_permission" "allow_bucket" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.uploads.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.uploads.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.processor.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}

# 6. API Gateway
resource "aws_api_gateway_rest_api" "image_api" {
  name = "ImageUploadAPI"
}

resource "aws_api_gateway_resource" "upload_resource" {
  rest_api_id = aws_api_gateway_rest_api.image_api.id
  parent_id   = aws_api_gateway_rest_api.image_api.root_resource_id
  path_part   = "upload"
}

resource "aws_api_gateway_method" "upload_method" {
  rest_api_id      = aws_api_gateway_rest_api.image_api.id
  resource_id      = aws_api_gateway_resource.upload_resource.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.image_api.id
  resource_id             = aws_api_gateway_resource.upload_resource.id
  http_method             = aws_api_gateway_method.upload_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.processor.invoke_arn
}

# 7. Deployment & Stage
resource "aws_api_gateway_deployment" "api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.image_api.id
  depends_on  = [aws_api_gateway_integration.lambda_integration]
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.image_api.id
  stage_name    = "prod"
}

# 8. API Key
resource "aws_api_gateway_api_key" "my_key" {
  name = "ProjectApiKey"
}

resource "aws_api_gateway_usage_plan" "my_plan" {
  name = "StandardUsagePlan"
  api_stages {
    api_id = aws_api_gateway_rest_api.image_api.id
    stage  = aws_api_gateway_stage.api_stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.my_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.my_plan.id
}

# 9. Permissions
resource "aws_lambda_permission" "api_gw_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.image_api.execution_arn}/*/*"
}

# 10. Outputs
output "api_url" {
  value = "${aws_api_gateway_stage.api_stage.invoke_url}/upload"
}

output "api_key_value" {
  value     = aws_api_gateway_api_key.my_key.value
  sensitive = true
}