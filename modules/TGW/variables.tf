################################################################################
# Providers
################################################################################
variable "region" {
  description = "region value"
  type        = string
}
################################################################################
# Tags
################################################################################
variable "name_TGW_Region" {
  description = "Name tag value"
  type        = string
}
################################################################################
# VPC
################################################################################
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}
################################################################################
# Subnets
################################################################################
variable "subnet3_id" {
  description = "CIDR block for subnet 3"
  type = string
}
variable "subnet4_id" {
  description = "CIDR block for subnet 4"
  type = string
}
