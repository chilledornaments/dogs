locals {
  default_tags = {
    project      = "dog-api"
    tf_workspace = terraform.workspace
    environment  = "production"
  }
}