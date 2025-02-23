locals {
  function_filename  = "login_auth"
  resource_timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
  lambda_dir_hash    = sha256(join("", [for f in fileset("${path.module}/lambdas/${local.function_filename}", "*"): filesha256("${path.module}/lambdas/${local.function_filename}/${f}")]))
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

data "template_file" "config_json" {
  template = file("${path.module}/lambdas/config.json.tpl")

  vars = {
    site_password = var.site_password
  }
}

# Create the Lambda ZIP file with the config.json file dynamically generated
resource "null_resource" "package_lambda" {
  provisioner "local-exec" {
    working_dir = "${path.module}/lambdas"
    interpreter = ["PowerShell", "-Command"]
    command     = <<-EOT
       '${data.template_file.config_json.rendered}' | Out-File -FilePath ./${local.function_filename}/config.json -Encoding utf8
      Compress-Archive -Path ./${local.function_filename}/* -DestinationPath ./${local.function_filename}.zip -Force
    EOT
  }
  triggers = {
    lambda_dir_hash = local.lambda_dir_hash
    config_hash     = data.template_file.config_json.rendered
  }
}

resource "aws_lambda_function" "auth_lambda" {
  filename      = "${path.module}/lambdas/${local.function_filename}.zip" # The zipped file containing the above JS code
  function_name = "login-auth-lambda-${local.resource_timestamp}"
  role          = aws_iam_role.lambda_edge_role.arn
  handler       = "${local.function_filename}.handler"
  runtime       = "nodejs18.x"
  publish       = true

  skip_destroy = true
}
