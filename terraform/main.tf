locals {
  default_tags = {
    project      = "dog-api"
    tf_workspace = terraform.workspace
    environment  = "production"
  }

  route53_zone_id = data.aws_route53_zone.dogs.id

  image_map_file_name = "image_map.txt"

  link_creator_managed_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  link_retriever_managed_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}
