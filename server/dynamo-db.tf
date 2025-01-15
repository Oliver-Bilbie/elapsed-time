resource "aws_dynamodb_table" "connections_table" {
  name           = "${var.app_name}-connections"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "connectionId"

  attribute {
    name = "connectionId"
    type = "S"
  }

  tags = {
    Name        = "${var.app_name}-connections"
    Description = "Connections table for ${var.app_name}"
    Environment = "production"
  }
}
