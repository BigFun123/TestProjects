variable "scheduled_lambda_fetch_url" {
  description = "URL to fetch in Scheduled Lambda"
  type        = string
  default     = "https://usermetrics.net/health"
}
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "lambda_package" {
  description = "Path to the Lambda deployment package zip file"
  default     = "../lambda.zip"
  type        = string
}

variable "node_lambda_package" {
  description = "Path to the Node.js Lambda deployment package zip file"
  default     = "../nodelambda.zip"
  type        = string
}

variable "node_lambda_fetch_url" {
  description = "URL to fetch in Node.js Lambda"
  type        = string
  default     = "https://usermetrics.net/health"
}
