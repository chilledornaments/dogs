resource "aws_route53_record" "images" {
  zone_id = data.aws_route53_zone.dogs.id
  name    = "images.${data.aws_route53_zone.dogs.name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.images.domain_name
    zone_id                = aws_cloudfront_distribution.images.hosted_zone_id
    evaluate_target_health = false
  }
}