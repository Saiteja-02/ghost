terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIA3DYPPLG37EDVNIMW"
  secret_key = "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"

}
