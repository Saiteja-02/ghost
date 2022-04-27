resource "aws_cloudwatch_log_group" "ghost_cloudwatch_logs" {
  name = "ghost"

  tags = {
    Environment = "production"
  }
}