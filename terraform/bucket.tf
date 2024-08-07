resource "aws_s3_bucket" "images" {
  bucket_prefix = "dog-api"
  force_destroy = var.destroy_bucket_objects_on_delete
}

data "aws_iam_policy_document" "images_bucket" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.images.arn}/img/*",
      "${aws_s3_bucket.images.arn}/index.html",
      "${aws_s3_bucket.images.arn}/favicon.ico"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.images.arn
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "images" {
  bucket = aws_s3_bucket.images.id
  policy = data.aws_iam_policy_document.images_bucket.json
}

resource "aws_s3_bucket_ownership_controls" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


# NOTE: only one `aws_s3_bucket_notification` per bucket is supported
resource "aws_s3_bucket_notification" "images_to_link_creator" {
  bucket = aws_s3_bucket.images.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.link_creator.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "upload/"
  }
}

resource "aws_s3_object" "image_map_file" {
  bucket  = aws_s3_bucket.images.bucket
  key     = local.image_map_file_name
  content = ""

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cleanup_uploads" {
  bucket = aws_s3_bucket.images.bucket

  rule {
    id     = "delete-upload"
    status = "Enabled"

    filter {
      prefix = "upload/"
    }

    expiration {
      days = 2
    }
  }

  rule {
    id     = "transition-to-infrequent"
    status = "Enabled"

    filter {
      prefix = "img/"
    }

    transition {
      days          = 30 # 30 is minimum
      storage_class = "STANDARD_IA"
    }
  }
}
