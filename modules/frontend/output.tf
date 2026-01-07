########################################
# OUTPUT FOR CLOUDFRONT URL
########################################
output "frontend_cloudfront_domain" {
  value = aws_cloudfront_distribution.frontend_cdn.domain_name
}