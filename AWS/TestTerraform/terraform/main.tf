provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "lambda_exec" {
  name = "scheduled_lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  inline_policy {
    name = "AllowGetSecretValue"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "scheduled_lambda" {
  function_name = "scheduled_lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "ScheduledLambda::ScheduledLambda.Function::FunctionHandler"
  runtime       = "dotnet8"
  filename      = var.lambda_package
  source_code_hash = filebase64sha256(var.lambda_package)
  timeout       = 30
  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda.id]
  }
  environment {
    variables = {
      FETCH_URL = var.scheduled_lambda_fetch_url
    }
  }
}

resource "aws_lambda_function" "node_lambda" {
  function_name = "node_lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  filename      = var.node_lambda_package
  source_code_hash = filebase64sha256(var.node_lambda_package)
  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda.id]
  }
  environment {
    variables = {
      FETCH_URL = var.node_lambda_fetch_url
    }
  }
  timeout       = 30
}

resource "aws_cloudwatch_event_rule" "every_3_hours" {
  name                = "every-3-hours"
  schedule_expression = "rate(3 hours)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_3_hours.name
  target_id = "lambda"
  arn       = aws_lambda_function.scheduled_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduled_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_3_hours.arn
}
