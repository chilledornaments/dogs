/*
This is the Python Lambda that is executed when an object is uploaded to the `upload/` path in the image bucket

It copies the image to the `img/` prefix and updates the "image_map.txt" file 
*/

resource "aws_cloudwatch_log_group" "link_creator" {
  name              = "/aws/lambda/${aws_lambda_function.link_creator.function_name}"
  retention_in_days = 7
  # I'd use KMS key to encrypt this but I don't want to spend the money on a custom KMS key
}

resource "aws_iam_role" "link_creator" {
  name               = "dog-api-link-creator"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "link_creator" {
  statement {
    sid    = "S3"
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:CopyObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.images.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "link_creator" {
  name   = "dog-api-link-creator"
  policy = data.aws_iam_policy_document.link_creator.json
}

resource "aws_iam_role_policy_attachment" "link_creator" {
  role       = aws_iam_role.link_creator.name
  policy_arn = aws_iam_policy.link_creator.arn
}

resource "aws_iam_role_policy_attachment" "link_creator_managed_policies" {
  for_each = toset(local.link_creator_managed_policies)

  role       = aws_iam_role.link_creator.name
  policy_arn = each.value
}

resource "aws_lambda_function" "link_creator" {
  function_name                  = "dog-api-link-creator"
  role                           = aws_iam_role.link_creator.arn
  filename                       = data.archive_file.lambda_seed.output_path
  runtime                        = "python3.11"
  memory_size                    = 256
  timeout                        = 20
  handler                        = "app.handler"
  reserved_concurrent_executions = var.link_creator_max_concurrent_executions

  environment {
    variables = {
      PYTHONUNBUFFERED = "1"
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_lambda_permission" "allow_s3_invoke_link_creator" {
  statement_id  = "AllowS3EventExecution"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.link_creator.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.images.arn
}
