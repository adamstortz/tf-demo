provider "aws" {
}

terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }

  }

  required_version = "~> 1.4"
  backend "s3" {
       bucket = "tf-demo-astortz"
       key    = "workload-tf-demo"
       region = "us-east-2"
   }
}
