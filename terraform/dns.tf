resource "aws_route53_record" "images" {
  zone_id = data.aws_route53_zone.dogs.id
  name    = "img.${data.aws_route53_zone.dogs.name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.images.domain_name
    zone_id                = aws_cloudfront_distribution.images.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "images_v6" {
  zone_id = data.aws_route53_zone.dogs.id
  name    = "img.${data.aws_route53_zone.dogs.name}"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.images.domain_name
    zone_id                = aws_cloudfront_distribution.images.hosted_zone_id
    evaluate_target_health = false
  }
}