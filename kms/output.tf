output kms_id {
  value       = aws_kms_key.kms_key.id
  description = "Kms_id"
}

output kms_arn {
  value       = aws_kms_key.kms_key.arn
  description = "kms_arn"
}
