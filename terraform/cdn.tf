locals {
  s3_origin_id = "images-bucket"
}

resource "aws_cloudfront_distribution" "images" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Dog images"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"


  aliases = concat([aws_acm_certificate.images.domain_name], tolist(aws_acm_certificate.images.subject_alternative_names))

  origin {
    domain_name = aws_s3_bucket.images.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
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
    cache_policy_id        = "CachingOptimized"
    min_ttl                = 86400
    max_ttl                = 31536000
    default_ttl            = 31536000 # cache for a year by default
  }
}
