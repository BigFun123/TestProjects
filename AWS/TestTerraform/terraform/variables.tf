variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "lambda_package" {
  description = "Path to the Lambda deployment package zip file"
  type        = string
}

variable "node_lambda_package" {
  description = "Path to the Node.js Lambda deployment package zip file"
  type        = string
}
