resource "aws_efs_file_system" "efs" {
  creation_token = "my-product"
  encrypted =   true
  kms_key_id = var.kms_arn
  performance_mode = var.performance_mode
  throughput_mode   =   var.throughput_mode
  tags = {
    Name = "MyProduct"
  }
}

resource "aws_efs_backup_policy" "efs_policy" {
  file_system_id = aws_efs_file_system.efs.id

  backup_policy {
    status = "ENABLED"
  }
}