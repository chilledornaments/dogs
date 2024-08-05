/*
This is the Python Lambda that is executed when an object is uploaded to the `upload/` path in the image bucket

It copies the image to the `img/` prefix and updates the "image_map.txt" file 
*/

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
      "s3:DeleteObject",
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

resource "aws_iam_role_policy_attachment" "name" {
  role       = aws_iam_role.link_creator.name
  policy_arn = aws_iam_policy.link_creator.arn
}

resource "aws_lambda_function" "link_creator" {
  function_name = "dog-api-link-creator"
  role          = aws_iam_role.link_creator.arn
  filename      = data.archive_file.lambda_seed.output_path
  runtime       = "python3.11"
  memory_size   = 256
  timeout       = 20
  handler       = "app.handler"

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.images.bucket
      IMAGES_HOSTNAME = aws_route53_record.images.name
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

