# SQS Queue
resource "aws_sqs_queue" "maqueue" {
  name                      = "maqueue01"               #MyQueue
  visibility_timeout_seconds = 30                       
  message_retention_seconds  = 86400                    
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
  description = "Policy for Lambda to access SQS, Bedrock, CloudWatch, and S3"

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
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"               
      },
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject", "s3:GetObject"],
        Resource = "arn:aws:s3:::pgr301-mabucket01/*"  
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
  function_name = "lambda-function-maka082"                     #MyLambdaFunction
  role          = aws_iam_role.lambda_exec_role.arn     
  handler       = "lambda.lambda_handler"               
  runtime       = "python3.9"                           

  s3_bucket = "pgr301-mabucket01"                       #My bucket
  s3_key    = "lambda/lambda.zip"                       

  memory_size = 512                                     
  timeout     = 30                                      

  environment {
    variables = {
      QUEUE_URL   = aws_sqs_queue.maqueue.id            
      BUCKET_NAME = "pgr301-mabucket01"                
    }
  }
}

# Allow SQS to Invoke Lambda
resource "aws_lambda_permission" "sqs_invoke" {
  statement_id  = "AllowSQSInvoke"                      
  action        = "lambda:InvokeFunction"               
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "sqs.amazonaws.com"                  
  source_arn    = aws_sqs_queue.maqueue.arn           
}

# SQS to Lambda Event Source Mapping
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn  = aws_sqs_queue.maqueue.arn         
  function_name     = aws_lambda_function.lambda_function.function_name
  batch_size        = 10                                
  enabled           = true                              
}
git