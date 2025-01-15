resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.app_name}_lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name = "websocket-lambda-execution-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:Scan", "dynamodb:PutItem", "dynamodb:DeleteItem"]
        Resource = aws_dynamodb_table.connections_table.arn
      },
      {
        Effect   = "Allow"
        Action   = ["ssm:PutParameter", "ssm:GetParameter"]
        Resource = aws_ssm_parameter.timestamp.arn
      },
      {
        Effect   = "Allow"
        Action   = ["execute-api:ManageConnections"]
        Resource = "${aws_apigatewayv2_api.websocket_api.execution_arn}/${aws_apigatewayv2_stage.websocket_stage.name}/POST/@connections/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}

resource "aws_lambda_function" "server" {
  function_name    = "${var.app_name}-server"
  runtime          = "python3.13"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "server.lambda_handler"
  timeout          = 10
  memory_size      = 128
  filename         = "${path.module}/../build/server/server.zip"
  source_code_hash = filebase64sha256("${path.module}/../build/server/server.zip")

  environment {
    variables = {
      CONNECTION_TABLE_NAME = aws_dynamodb_table.connections_table.name
      WEBSOCKET_ENDPOINT    = "${aws_apigatewayv2_api.websocket_api.api_endpoint}/${aws_apigatewayv2_stage.websocket_stage.name}"
      TIMESTAMP_PARAMETER   = aws_ssm_parameter.timestamp.name
    }
  }
}
