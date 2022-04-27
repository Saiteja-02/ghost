variable "cidr_block" {
  default = "10.0.0.0/24"
}

/* kms */
variable "key" {
  default = "dev"
}

/* vpc variables */



/* rds variables */
variable "availability_zones" {
  type        = list(any)
  default     = ["ap-south-1a", "ap-south-2a"]
  description = "availability_zones"
}

variable "master_username" {
  type        = string
  default     = "root"
  description = "master_username"
}

variable "engine" {
  type        = string
  default     = "aurora-mysql"
  description = "engine"
}

variable "engine_mode" {
  type        = string
  default     = "serverless"
  description = "engine_mode"
}

variable "engine_version" {
  type        = string
  default     = "5.7.mysql_aurora.2.03.2"
  description = "engine_version"
}


variable "preferred_backup_window" {
  type        = string
  default     = "07:00-09:00"
  description = "preferred_backup_window"
}


variable "database_name" {
  type        = string
  default     = "ghost"
  description = "database_name"
}


variable "master_password" {
  type        = string
  default     = "Terraform@123"
  description = "master_password"
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "backup_retention_period"
}

variable "cluster_identifier" {
  type        = string
  default     = "aurora-cluster-ghost"
  description = "cluster_identifier"
}
