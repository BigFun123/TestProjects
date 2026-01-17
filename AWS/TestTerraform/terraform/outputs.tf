output "lambda_function_name" {
  value = aws_lambda_function.scheduled_lambda.function_name
}

output "eventbridge_rule_arn" {
  value = aws_cloudwatch_event_rule.every_24_hours.arn
}
