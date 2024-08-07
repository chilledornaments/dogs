locals {
  s3_origin_id = "images-bucket"
}

resource "aws_cloudfront_origin_access_control" "images" {
  name                              = "dog-images"
  description                       = "Allow dog images CloudFront to read images and HTML"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "s3_optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "images" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Dog images"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"


  aliases = concat([aws_acm_certificate.images.domain_name], tolist(aws_acm_certificate.images.subject_alternative_names))

  origin {
    domain_name              = aws_s3_bucket.images.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.images.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.images.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = data.aws_cloudfront_cache_policy.s3_optimized.id
  }
}
