#Variable that defines the name of the SQS queue 
variable "sqs_queue_name" {
  description = "SQS queue name"
  type        = string
  default     = "maqueue01"
}
#Variable that specifies the name of the lambda function
variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
  default     = "lambda-function"
}
#Variable that specifies the name of the S3 bucket
variable "lambda_s3_bucket" {
  description = "S3 bucket name"
  type        = string
  default     = "pgr301-couch-explorers"
}
#This variable is used to specify the path to the lambda functions deployment package
variable "lambda_s3_key" {
  description = "S3 key for lambda"
  type        = string
  default     = "lambda/lambda.zip"
}

#Variable that specifies the email adress that recieves notifications
variable "alarm_email" {
  description = "Email address that recives the cloudwatch alarm notifications"
  type        = string
}
