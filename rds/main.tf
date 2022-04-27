resource "aws_rds_cluster" "default" {
  cluster_identifier      = var.cluster_identifier
  allow_major_version_upgrade = true
  apply_immediately       = false
  copy_tags_to_snapshot = true
  engine                  = var.engine
  engine_mode             = var.engine_mode
  engine_version          = var.engine_version
  availability_zones      = var.availability_zones
  database_name           = var.database_name
  db_cluster_parameter_group_name  = var.db_cluster_parameter_group
  db_instance_parameter_group_name  = var.db_instance_parameter_group
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.id
  master_username         = var.master_username
  master_password         = var.master_password
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  enabled_cloudwatch_logs_exports = var.engine_mode == "serverless" ? [] : var.logs
  vpc_security_group_ids  = var.db_security_group_ids

  storage_encrypted       = true
  kms_key_id              = var.kms_arn
}


resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "subnet group aurora serverless"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "aurora db subnet group"
  }
}
