resource "aws_route53_record" "images" {
  zone_id = local.route53_zone_id
  name    = "img.${data.aws_route53_zone.dogs.name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.images.domain_name
    zone_id                = aws_cloudfront_distribution.images.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "images_v6" {
  zone_id = local.route53_zone_id
  name    = "img.${data.aws_route53_zone.dogs.name}"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.images.domain_name
    zone_id                = aws_cloudfront_distribution.images.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api" {
  zone_id = local.route53_zone_id
  name    = aws_api_gateway_domain_name.link_retriever.domain_name
  type    = "A"

  alias {
    zone_id                = aws_api_gateway_domain_name.link_retriever.regional_zone_id
    name                   = aws_api_gateway_domain_name.link_retriever.regional_domain_name
    evaluate_target_health = false
  }
}
