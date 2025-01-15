resource "aws_ssm_parameter" "timestamp" {
  name  = "${var.app_name}-timestamp"
  type  = "String"
  value = " "

  lifecycle {
    ignore_changes = [value]
  }
}
