terraform {
  backend "s3" {
    bucket         = "pgr301-2024-terraform-state"
    key            = "lambda-sqs-integration/terraform.tfstate"
    region         = "eu-west-1"
  }
}
