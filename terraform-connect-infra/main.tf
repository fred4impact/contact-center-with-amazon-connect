
provider "aws" {
  region = var.region
}

# S3 bucket for call prompts (MP3 files)
resource "aws_s3_bucket" "prompt_bucket" {
  bucket = var.s3_bucket_name
}

# DynamoDB table to store appointments
resource "aws_dynamodb_table" "appointments" {
  name           = "Appointments"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PhoneNumber"

  attribute {
    name = "PhoneNumber"
    type = "S"
  }

  tags = {
    Name = "AppointmentTable"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_connect_appointment_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy Attachment
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "appointment_handler" {
  function_name = "AppointmentSchedulerLambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "appointment_scheduler.lambda_handler"
  runtime       = "python3.9"
  filename      = data.archive_file.lambda_zip.output_path
  timeout       = 10
}
