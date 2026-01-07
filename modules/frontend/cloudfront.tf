########################################
# ORIGIN ACCESS CONTROL (OAC)
########################################
resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name                              = "oac-${aws_s3_bucket.frontend_bucket.bucket}"
  description                       = "OAC for ${aws_s3_bucket.frontend_bucket.bucket}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

########################################
# CLOUD FRONT DISTRIBUTION
########################################
resource "aws_cloudfront_distribution" "frontend_cdn" {
  enabled             = true
  default_root_object = "index.html"
  comment             = "CDN for ${aws_s3_bucket.frontend_bucket.bucket}"

  # Add your custom domains here
  aliases = [var.domain_name]

  tags = {
    Name        = local.distribution_name
  }

  ###########################
  # ORIGIN BLOCK
  ###########################
  origin {
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id                = "s3-origin-${aws_s3_bucket.frontend_bucket.bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id
  }

  ###########################
  # CACHE BEHAVIOR
  ###########################
  default_cache_behavior {
    target_origin_id       = "s3-origin-${aws_s3_bucket.frontend_bucket.bucket}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    compress = true
    # AWS Managed Cache Policy: CachingOptimized
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  ###########################
  # GEO RESTRICTION
  ###########################
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  ###########################
  # SSL
  ###########################
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}



