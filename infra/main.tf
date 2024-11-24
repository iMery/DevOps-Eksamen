#SQS Queue
resource "aws_sqs_queue" "maqueue" {
  name                      = "maqueue01"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400
}

#IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role_maka"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

#IAM Policy for Lambda Execution
resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "lambda_exec_policy_maka"
  description = "Policy for Lambda to access SQS and S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
        Resource = aws_sqs_queue.maqueue.arn
      },
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
        Resource = [
          "arn:aws:s3:::pgr301-couch-explorers",
          "arn:aws:s3:::pgr301-couch-explorers/28/*",
          "arn:aws:s3:::pgr301-couch-explorers/images/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow",
        Action   = ["bedrock:InvokeModel"],
        Resource = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-image-generator-v1"
      }
    ]
  })
}


#Attach the IAM Policy to the Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}

#Lambda Function
resource "aws_lambda_function" "lambda_function" {
  function_name = "lambda-function-maka082"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda.lambda_handler"
  runtime       = "python3.9"

  s3_bucket = "pgr301-2024-terraform-state" #Stated bucket
  s3_key    = "28/lambda.zip"

  memory_size = 512
  timeout     = 30

  environment {
    variables = {
      QUEUE_URL   = aws_sqs_queue.maqueue.id
      BUCKET_NAME = "pgr301-couch-explorers"  #Bucket that has the generated images -- images are generated in the folder images/
    }
  }
}


#Allow SQS to Invoke Lambda
resource "aws_lambda_permission" "sqs_invoke" {
  statement_id  = "AllowSQSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.maqueue.arn
}

#SQS to Lambda Event Source Mapping
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn  = aws_sqs_queue.maqueue.arn
  function_name     = aws_lambda_function.lambda_function.function_name
  batch_size        = 10
  enabled           = true
}

#SNS topic
resource "aws_sns_topic" "alarm_topic" {
  name = "sqs-cloudwatch-alarm-topic"
}

#Topic subscribtion to send email notifications
resource "aws_sns_topic_subscription" "alarm_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

#Cloudwatch alarm 
resource "aws_cloudwatch_metric_alarm" "sqs_oldest_message_alarm" {
  alarm_name          = "SQSOldestMessageAgeHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 120  
  alarm_description   = "Alarm triggers when the age of the oldest SQS message exceeds the threshold"
  dimensions = {
    QueueName = aws_sqs_queue.maqueue.name
  }

  actions_enabled = true
  alarm_actions   = [aws_sns_topic.alarm_topic.arn]
}

