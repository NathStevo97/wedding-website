locals {
  function_filename  = "login_auth"
  resource_timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
  lambda_dir_hash    = sha256(join("", [for f in fileset("${path.module}/lambdas/${local.function_filename}", "*") : filesha256("${path.module}/lambdas/${local.function_filename}/${f}")]))
}

resource "aws_iam_role" "lambda_edge_role" {
  name = "lambda-edge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "edgelambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_edge_policy_attachment" {
  name       = "lambda-edge-policy-attachment"
  roles      = [aws_iam_role.lambda_edge_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "local_file" "config_json" {
  filename = "${path.module}/lambdas/${local.function_filename}/config.json"
  content = templatefile("${path.module}/lambdas/config.json.tpl", {
    site_password = var.site_password
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/${local.function_filename}"
  output_path = "${path.module}/lambdas/${local.function_filename}.zip"

  depends_on = [local_file.config_json]
}

resource "aws_lambda_function" "auth_lambda" {
  #checkov:skip=CKV_AWS_50: Lambda@Edge does not support X-Ray tracing.
  #checkov:skip=CKV_AWS_272: Lambda@Edge does not support Lambda code-signing configurations.
  #checkov:skip=CKV_AWS_115: Lambda@Edge does not support reserved concurrency limits.
  #checkov:skip=CKV_AWS_117: Lambda@Edge functions cannot be attached to a VPC.
  #checkov:skip=CKV_AWS_116: Lambda@Edge does not support dead-letter queues.
  filename         = data.archive_file.lambda_zip.output_path # The zipped file containing the above JS code
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "login-auth-lambda"
  role             = aws_iam_role.lambda_edge_role.arn
  handler          = "${local.function_filename}.handler"
  runtime          = "nodejs22.x"
  publish          = true

  skip_destroy = true
}
