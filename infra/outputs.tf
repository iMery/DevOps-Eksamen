output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.maqueue.id
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.lambda_function.arn
}
