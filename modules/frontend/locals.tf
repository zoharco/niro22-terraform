# Local variables, to use in the current directory.

locals {
  bucket_name = "niro-front-end-${data.aws_caller_identity.caller_identity.account_id}"
  distribution_name = "${var.company_name}-distribution"
}