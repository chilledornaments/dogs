/*
This is the Go Lambda that is executed when a user makes a request to `/api/random`

It returns an ID from the "image_map.txt" file. Note that the image_map file is cached in memory during execution in
order to reduce S3 calls
*/

resource "aws_cloudwatch_log_group" "link_retriever" {
  name              = "/aws/lambda/${aws_lambda_function.link_retriever.function_name}"
  retention_in_days = 7
  # I'd use KMS key to encrypt this but I don't want to spend the money on a custom KMS key
}

resource "aws_iam_role" "link_retriever" {
  name               = "dog-api-link-retriever"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "link_retriever" {
  statement {
    sid    = "S3"
    effect = "Allow"
    actions = [
      "s3:Get*",
    ]

    resources = [
      "${aws_s3_bucket.images.arn}/${local.image_map_file_name}",
    ]
  }
}

resource "aws_iam_policy" "link_retriever" {
  name   = "dog-api-link-retriever"
  policy = data.aws_iam_policy_document.link_retriever.json
}

resource "aws_iam_role_policy_attachment" "link_retriever" {
  role       = aws_iam_role.link_retriever.name
  policy_arn = aws_iam_policy.link_retriever.arn
}

resource "aws_iam_role_policy_attachment" "link_retriever_managed_policies" {
  for_each = toset(local.link_retriever_managed_policies)

  role       = aws_iam_role.link_retriever.name
  policy_arn = each.value
}

resource "aws_lambda_function" "link_retriever" {
  function_name = "dog-api-link-retriever"
  role          = aws_iam_role.link_retriever.arn
  filename      = data.archive_file.lambda_seed.output_path
  runtime       = "provided.al2023"
  handler       = "bootstrap"
  memory_size   = 128
  timeout       = 5

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.images.bucket
      DOMAIN_NAME = aws_route53_record.images.name
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_lambda_permission" "allow_s3_invoke_link_retriever" {
  statement_id  = "AllowAPIGWExecution"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.link_retriever.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.link_retriever.arn}/*/${aws_api_gateway_method.link_retriever_get_random.http_method}${aws_api_gateway_resource.link_retriever_random.path}"
}

