
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
    bucket         = "tf-remote-backend-backstage"  # Name of your S3 bucket
    key            = "terraform.tfstate"            # The key within the bucket where the state file will be stored
    region         = "ap-south-1"                  # AWS region of the bucket
    encrypt        = true                           # Encrypt the state file
    dynamodb_table = "terraform-lock-table"         # Optional: DynamoDB table for state locking and consistency checks
  }
}

provider "aws" {
  region     = var.awsRegion
}

resource "aws_instance" "example_server" {
  ami           = "ami-068e0f1a600cd311c"
  instance_type = var.instanceType

  tags = {
    Name = var.instanceName
  }
}
