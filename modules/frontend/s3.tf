resource "aws_s3_bucket" "frontend_bucket" {
  bucket = local.bucket_name
  force_destroy = false

  tags = {
    Name        = local.bucket_name
    Company      = var.company_name
    Environment = var.environment
  }
}

# Block all public access (recommended)
resource "aws_s3_bucket_public_access_block" "frontend_bucket_block" {
  bucket                  = aws_s3_bucket.frontend_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# (Optional) Default encryption
# resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_bucket_encryption" {
#   bucket = aws_s3_bucket.frontend_bucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }


########################################
# S3 BUCKET POLICY FOR OAC
########################################
resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2008-10-17",
    Id = "PolicyForCloudFrontPrivateContent",
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" : aws_cloudfront_distribution.frontend_cdn.arn
          }
        }
      }
    ]
  })
}
