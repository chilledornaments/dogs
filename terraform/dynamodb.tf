# This stores a list of file names 
resource "aws_dynamodb_table" "images" {
  name = "dog-api-images"

}