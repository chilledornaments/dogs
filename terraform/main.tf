locals {
  default_tags = {
    project      = "dog-api"
    tf_workspace = terraform.workspace
    environment  = "production"
  }

  link_creator_managed_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  link_retriever_managed_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
}