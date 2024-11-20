# SQS Queue
resource "aws_sqs_queue" "maqueue" {
  name                      = "maqueue01"               # Name of the SQS queue
  visibility_timeout_seconds = 30                       # Time a message is invisible after being read
  message_retention_seconds  = 86400                    # Time a message is retained in the queue
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role_maka"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"             # Allow Lambda to assume this role
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Lambda Execution
resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "lambda_exec_policy_maka"
  description = "Policy for Lambda to access SQS, Bedrock, CloudWatch, and S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
        Resource = aws_sqs_queue.maqueue.arn          # Allow access to the SQS queue
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"               # Allow Lambda to log to CloudWatch
      },
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:GetObject"],
        Resource = "arn:aws:s3:::pgr301-mabucket01/*"  # Allow Lambda to upload to and read from S3
      },
      {
        Effect   = "Allow",
        Action   = ["bedrock:InvokeModel"],            # Allow invoking Bedrock models
        Resource = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"
      }
    ]
  })
}

# Attach the IAM Policy to the Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name       # Attach to the Lambda execution role
  policy_arn = aws_iam_policy.lambda_exec_policy.arn    # Use the created policy
}

# Lambda Function
resource "aws_lambda_function" "lambda_function" {
  function_name = "lambda-function-maka082"                     # Name of the Lambda function
  role          = aws_iam_role.lambda_exec_role.arn     # IAM Role for the Lambda function
  handler       = "lambda.lambda_handler"               # Specify handler (file.function)
  runtime       = "python3.9"                           # Python runtime version

  s3_bucket = "pgr301-mabucket01"                       # S3 bucket containing the Lambda ZIP file
  s3_key    = "lambda/lambda.zip"                       # Path to the ZIP file in the bucket

  memory_size = 512                                     # Set memory to 512 MB or higher
  timeout     = 30                                      # Set timeout to 30 seconds

  environment {
    variables = {
      QUEUE_URL   = aws_sqs_queue.maqueue.id            # Pass the SQS queue URL as an environment variable
      BUCKET_NAME = "pgr301-mabucket01"                # Pass the S3 bucket name as an environment variable
    }
  }
}

# Allow SQS to Invoke Lambda
resource "aws_lambda_permission" "sqs_invoke" {
  statement_id  = "AllowSQSInvoke"                      # Unique statement ID
  action        = "lambda:InvokeFunction"               # Allow Lambda invocation
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "sqs.amazonaws.com"                  # Allow SQS to invoke Lambda
  source_arn    = aws_sqs_queue.maqueue.arn            # Specific SQS queue ARN
}

# SQS to Lambda Event Source Mapping
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn  = aws_sqs_queue.maqueue.arn         # SQS queue ARN
  function_name     = aws_lambda_function.lambda_function.function_name
  batch_size        = 10                                # Number of messages per batch
  enabled           = true                              # Enable the mapping
}
