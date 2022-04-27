variable kms_arn {}

variable performance_mode {
  type        = string
  default     = "generalPurpose"
  description = "performance_mode"
}

variable throughput_mode {
  type        = string
  default     = "bursting"
  description = "throughput_mode"
}

