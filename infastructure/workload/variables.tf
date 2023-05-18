variable "image_version" {
  description = "The version to tag the image with"
  type        = string
  default     = "local"
}

variable "ingress_cidr_block" {
  description = "List of CIDRs to allow ingress"
  type        = string
  default     = ""
}