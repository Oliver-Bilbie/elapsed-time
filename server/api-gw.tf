resource "aws_apigatewayv2_api" "websocket_api" {
  name                       = "${var.app_name}-websocket-api"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_stage" "websocket_stage" {
  api_id      = aws_apigatewayv2_api.websocket_api.id
  name        = "prod"
  auto_deploy = true
}

resource "aws_apigatewayv2_route" "connect_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "$connect"

  target = "integrations/${aws_apigatewayv2_integration.connect_integration.id}"
}

resource "aws_apigatewayv2_route" "disconnect_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "$disconnect"

  target = "integrations/${aws_apigatewayv2_integration.disconnect_integration.id}"
}

resource "aws_apigatewayv2_route" "get_time_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "get_time"

  target = "integrations/${aws_apigatewayv2_integration.get_time_integration.id}"
}

resource "aws_apigatewayv2_route" "reset_time_route" {
  api_id    = aws_apigatewayv2_api.websocket_api.id
  route_key = "reset_time"

  target = "integrations/${aws_apigatewayv2_integration.reset_time_integration.id}"
}

resource "aws_apigatewayv2_integration" "connect_integration" {
  api_id             = aws_apigatewayv2_api.websocket_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.server.arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "disconnect_integration" {
  api_id             = aws_apigatewayv2_api.websocket_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.server.arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "get_time_integration" {
  api_id             = aws_apigatewayv2_api.websocket_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.server.arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "reset_time_integration" {
  api_id             = aws_apigatewayv2_api.websocket_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.server.arn
  integration_method = "POST"
}

resource "aws_lambda_permission" "connect_permission" {
  statement_id  = "AllowAPIGatewayConnect"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.server.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*"
}

resource "aws_lambda_permission" "disconnect_permission" {
  statement_id  = "AllowAPIGatewayDisconnect"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.server.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*"
}

resource "aws_lambda_permission" "get_time_permission" {
  statement_id  = "AllowAPIGatewayGetTime"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.server.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*"
}

resource "aws_lambda_permission" "reset_time_permission" {
  statement_id  = "AllowAPIGatewayResetTime"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.server.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*"
}

output "websocket_endpoint" {
  value = "${aws_apigatewayv2_api.websocket_api.api_endpoint}/${aws_apigatewayv2_stage.websocket_stage.name}"
}
