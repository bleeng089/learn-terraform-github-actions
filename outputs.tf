# Output the VPC ID from the vpc child module
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc_japan.vpc_id
}

# Output the Subnet IDs from the vpc child module
output "subnet1_id" {
  description = "The ID of subnet 1"
  value       = module.vpc_japan.subnet1_id
}

output "subnet2_id" {
  description = "The ID of subnet 2"
  value       = module.vpc_japan.subnet2_id
}

output "subnet3_id" {
  description = "The ID of subnet 3"
  value       = module.vpc_japan.subnet3_id
}

output "subnet4_id" {
  description = "The ID of subnet 4"
  value       = module.vpc_japan.subnet4_id
}
# Output the ALB DNS from the infrastructure child module
output "ALB-DNS-japan" {
  description = "The ID of the ALB DNS"
  value       = module.infrastructure_japan.ALB-DNS
}
output "ALB-DNS-NewYork" {
  description = "The ID of the ALB DNS"
  value       = module.infrastructure_NewYork.ALB-DNS
}
output "ALB-DNS-Brazil" {
  description = "The ID of the ALB DNS"
  value       = module.infrastructure_Brazil.ALB-DNS
}
output "ALB-DNS-Sydney" {
  description = "The ID of the ALB DNS"
  value       = module.infrastructure_Sydney.ALB-DNS
}
output "ALB-DNS-HongKong" {
  description = "The ID of the ALB DNS"
  value       = module.infrastructure_HongKong.ALB-DNS
}
output "ALB-DNS-Cali" {
  description = "The ID of the ALB DNS"
  value       = module.infrastructure_Cali.ALB-DNS
}
