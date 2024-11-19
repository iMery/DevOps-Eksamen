variable "sqs_queue_name" {
  description = "Navn på SQS køen"
  type        = string
  default     = "maqueue01"
}

variable "lambda_function_name" {
  description = "Navn på Lambda-funksjonen"
  type        = string
  default     = "lambda-function"
}

variable "lambda_s3_bucket" {
  description = "Navn på S3 bucket for Lambda kode"
  type        = string
  default     = "pgr301-2024-lambda-code"
}

variable "lambda_s3_key" {
  description = "S3 nøkkel for Lambda kode"
  type        = string
  default     = "lambda/lambda.zip"
}

variable "image_s3_bucket" {
  description = "S3 bucket for genererte bilder"
  type        = string
  default     = "generated-images-bucket"
}
