terraform {
  required_version = ">= 1.0" # TODO when was optional added?

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}