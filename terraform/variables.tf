variable "aws" {
  type = object({
    region   = optional(string, "us-east-2")
    role_arn = string
  })
}