resource "aws_lambda_function" "link_creator" {
  role          = "dog-api-link-creator"
  function_name = ""
}

resource "aws_lambda_permission" "allow_s3_invoke_link_creator" {
  statement_id  = "AllowS3EventExecution"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.link_creator.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.images.arn
}

