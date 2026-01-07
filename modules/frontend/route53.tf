#######################
# Route53 Hosted Zone #
#######################

resource "aws_route53_zone" "main_zone" {
  name = var.domain_name
}

##########################################
# Route53 DNS validation record for ACM  #
##########################################

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.resource_record_name => dvo...
  }

  zone_id = aws_route53_zone.main_zone.zone_id
  name    = each.value[0].resource_record_name
  type    = each.value[0].resource_record_type
  ttl     = 300
  records = [each.value[0].resource_record_value]
}

################################################
# CloudFront DNS record (exactly one)
################################################

resource "aws_route53_record" "root_cdn_record" {
  zone_id = aws_route53_zone.main_zone.zone_id

  name = var.domain_name          # e.g. "niro22.com"
  type = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}