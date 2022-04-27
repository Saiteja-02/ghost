variable "public_subnet_ids"{}
variable "private_subnet_ids"{
    type=list(string)
}
variable "vpc_id"{}
variable "private_sg_ASG" {}
variable "availability_zones_ASG" {
    type=list(string)  
}
