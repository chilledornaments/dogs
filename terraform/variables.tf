variable "aws" {
  type = object({
    region   = optional(string, "us-east-2")
  })
}