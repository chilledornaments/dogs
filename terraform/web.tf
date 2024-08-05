resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.images.bucket
  key          = "index.html"
  source       = "${path.module}/../web/index.html"
  etag         = filemd5("${path.module}/../web/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "favicon" {
  bucket = aws_s3_bucket.images.bucket
  key    = "favicon.ico"
  source = "${path.module}/../web/favicon.ico"
  etag   = filemd5("${path.module}/../web/favicon.ico")
}
