locals {
    function_filename = "login_auth"
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

resource "aws_lambda_function" "auth_lambda" {
  filename         = "${path.module}/${local.function_filename}.zip" # The zipped file containing the above JS code
  function_name    = "login-auth-lambda"
  role             = aws_iam_role.lambda_edge_role.arn
  handler          = "${local.function_filename}.handler"
  runtime          = "nodejs18.x"
  publish          = true

  skip_destroy = true
}
