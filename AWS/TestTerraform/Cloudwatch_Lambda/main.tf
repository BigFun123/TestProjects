terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# SQS Queue
resource "aws_sqs_queue" "main_queue" {
  name                      = "${var.project_name}-queue"
  visibility_timeout_seconds = 300
  message_retention_seconds = 345600

  tags = {
    Name        = "${var.project_name}-queue"
    Environment = var.environment
  }
}

# Lambda IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda IAM Policy
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.main_queue.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "sqs_processor" {
  filename      = "lambda_function.zip"
  function_name = "${var.project_name}-sqs-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.11"
  timeout       = 60

  source_code_hash = filebase64sha256("lambda_function.zip")

  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.main_queue.url
    }
  }

  tags = {
    Name        = "${var.project_name}-lambda"
    Environment = var.environment
  }
}

# Lambda Event Source Mapping
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.main_queue.arn
  function_name    = aws_lambda_function.sqs_processor.arn
  batch_size       = 10
  enabled          = true
}

# CloudWatch Alarm for SQS Messages
resource "aws_cloudwatch_metric_alarm" "sqs_messages_alarm" {
  alarm_name          = "${var.project_name}-sqs-messages-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Average"
  threshold           = var.alarm_threshold
  alarm_description   = "Alarm when SQS queue has messages"
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.main_queue.name
  }

  tags = {
    Name        = "${var.project_name}-alarm"
    Environment = var.environment
  }
}
