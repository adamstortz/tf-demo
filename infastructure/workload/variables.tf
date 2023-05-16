variable "image_version" {
  description = "The version to tag the image with"
  type        = string
  default     = "local"
}

variable "region" {
  description = "The AWS Region to deploy into"
  type        = string
  default     = "us-east-2"
}