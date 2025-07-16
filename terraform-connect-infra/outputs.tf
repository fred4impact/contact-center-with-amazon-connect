
output "lambda_function_name" {
  value = aws_lambda_function.appointment_handler.function_name
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.appointments.name
}

output "s3_bucket" {
  value = aws_s3_bucket.prompt_bucket.bucket
}
