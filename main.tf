module "vpc_networking" {
  source     = "./vpc"
  cidr_block = var.cidr_block
  key        = var.key
}


module "ec2_compute" {
  source             = "./ec2"
  public_subnet_ids  = module.vpc_networking.public_subnet_ids
  private_subnet_ids = module.vpc_networking.private_subnet_ids
  vpc_id             = module.vpc_networking.vpc_id
  private_sg_ASG     = module.vpc_networking.private_sg_ASG
  availability_zones_ASG = module.vpc_networking.availability_zones_ASG

}


module "kms_key" {
  source = "./kms"
  key    = var.key
}


module "rds_storage" {
  source                = "./rds"
  kms_arn               = module.kms_key.kms_arn
  subnet_ids            = module.vpc_networking.private_subnet_ids
  db_security_group_ids = [module.vpc_networking.db_sg]
  logs                         = ["error", "general", "slowquery"]

}


module "efs_storage" {
  source  = "./efs"
  kms_arn = module.kms_key.kms_arn
}

module "cloudwatch_logs" {
  source = "./cloudwatch"
  kms_key_id  = module.kms_key.kms_arn
  
}

/* 
module "S3_logs" {
  source = "./s3"
  kms_arn  = module.kms_key.kms_arn
}

doubts
1. protocol =-1 (in sg egrees)
2. how to send cloud watch logs to s3 using terraform
3. how to store snapshots in diff region using terraform
 */



