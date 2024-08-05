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
