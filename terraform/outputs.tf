output "api_url" {
  value = "https://${aws_api_gateway_base_path_mapping.api.domain_name}/${aws_api_gateway_base_path_mapping.api.base_path}/random"
}

output "bucket_name" {
  value = aws_s3_bucket.images.bucket
}

resource "local_file" "environment_file" {
  count = var.create_environment_file ? 1 : 0

  filename = "/tmp/test_terraform_environment"
  content  = <<EOF
export BUCKET_NAME='${aws_s3_bucket.images.bucket}'
export API_URL='https://${aws_api_gateway_base_path_mapping.api.domain_name}/${aws_api_gateway_base_path_mapping.api.base_path}/random'

EOF
}
