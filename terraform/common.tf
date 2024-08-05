data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "archive_file" "lambda_seed" {
  type        = "zip"
  output_path = "./seed.zip"

  source {
    content  = "hello"
    filename = "hello.txt"
  }
}