variable "environment" {
  type    = string
  default = "production"
}

variable "aws" {
  type = object({
    region = optional(string, "us-east-2")
  })
}

variable "domain" {
  type        = string
  description = "Domain name under which `img` and `api` records will be created"
}

variable "destroy_bucket_objects_on_delete" {
  type    = bool
  default = false
}

variable "create_environment_file" {
  type    = bool
  default = false
}

variable "link_creator_max_concurrent_executions" {
  type    = number
  default = 1
}
