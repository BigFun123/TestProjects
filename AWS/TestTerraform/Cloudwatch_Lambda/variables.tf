variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "sqs-lambda-project"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "alarm_threshold" {
  description = "Threshold for CloudWatch alarm (number of messages)"
  type        = number
  default     = 1
}
