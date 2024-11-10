locals {
  www_domain = "www.${var.domain_name}"
}

data "template_file" "config_json" {
  template = file("${path.module}/config.json.tpl")

  vars = {
    site_password = var.site_password
  }
}

# S3 bucket to store the Lambda@Edge function
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${local.www_domain}-auth-lambda-bucket"
  force_destroy = true
}

# Create the Lambda ZIP file with the config.json file dynamically generated
resource "null_resource" "package_lambda" {
  provisioner "local-exec" {
    working_dir = "${path.module}"
    interpreter = ["PowerShell", "-Command"]
    command = <<-EOT
      New-Item -ItemType Directory -Path ./lambda_package

      Copy-Item -Path ./auth_function.js -Destination ./lambda_package/auth_function.js -Force

      '${data.template_file.config_json.rendered}' | Out-File -FilePath ./lambda_package/config.json -Encoding utf8 -Force

      Compress-Archive -Path ./lambda_package/* -DestinationPath ./auth_function.zip -Force
    EOT
  }

  triggers = {
    config_hash = data.template_file.config_json.rendered
    always_run = timestamp()
  }
}

# Upload the ZIP to S3
resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_bucket.bucket
  key    = "auth_function.zip"
  source = "${path.module}/auth_function.zip"
  depends_on = [null_resource.package_lambda]
}

# IAM role for Lambda@Edge function
resource "aws_iam_role" "lambda_edge_role" {
  name = "lambda-edge-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "edgelambda.amazonaws.com"
          ]
        }
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
}

# IAM policy for Lambda@Edge to interact with CloudFront
resource "aws_iam_role_policy" "lambda_edge_policy" {
  name   = "lambda-edge-policy"
  role   = aws_iam_role.lambda_edge_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "cloudfront:GetDistribution",
          "cloudfront:UpdateDistribution"
        ],
        Resource = "*"
      }
    ]
  })
}

# Create the Lambda function from the ZIP
resource "aws_lambda_function" "auth_function" {
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = "auth_function.zip"
  function_name    = "authEdgeLambda"
  role             = aws_iam_role.lambda_edge_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  publish          = true
  skip_destroy     = true
}

resource "aws_lambda_permission" "allow_cloudfront" {
  statement_id  = "AllowExecutionFromCloudFront"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_function.function_name
  principal     = "cloudfront.amazonaws.com" # might need to change to cloudfront.amazonaws.com instead of edgelambda.amazonaws.com?
  source_arn    = aws_cloudfront_distribution.s3_distribution.arn
}