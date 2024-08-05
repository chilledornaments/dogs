resource "aws_s3_bucket" "images" {
  bucket_prefix = "dog-api"
}

resource "aws_s3_bucket_acl" "images" {
  bucket = aws_s3_bucket.images.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "images" {
  bucket = aws_s3_bucket.images.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.images.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.images.arn}/*"
      }
    ]
  })
}

# NOTE: only one `aws_s3_bucket_notification` per bucket is supported
resource "aws_s3_bucket_notification" "images_to_link_creator" {
  count = 0
  
  bucket = aws_s3_bucket.images.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.link_creator.arn
    events              = ["S3:ObjectCreated:*"]
    filter_prefix       = "upload/"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cleanup_uploads" {
bucket = aws_s3_bucket.images.bucket

rule {
  id = "delete-upload"
  status = "Enabled"

  filter {
    prefix = "upload/"
  }

  expiration {
    days = 2
  }
}

rule {
  id = "transition-to-infrequent"
  status = "Enabled"

  filter {
    prefix = "img/"
  }

  transition {
    days = 3
    storage_class = "STANDARD_IA"
  }
}
}