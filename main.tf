# Lambda-funksjon
resource "aws_lambda_function" "lambda_function" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda.lambda_handler" # Riktig handler fra lambda.py
  runtime       = "python3.9"

  s3_bucket = var.lambda_s3_bucket
  s3_key    = var.lambda_s3_key

  environment {
    variables = {
      QUEUE_URL   = aws_sqs_queue.maqueue.id
      BUCKET_NAME = var.image_s3_bucket 
    }
  }
}
