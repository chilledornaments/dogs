output "image_url" {
  value = "https://${aws_api_gateway_base_path_mapping.api.domain_name}/${aws_api_gateway_base_path_mapping.api.base_path}/random"
}
