################################################################################
# Version
################################################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
################################################################################
# Providers
################################################################################
provider "aws" {
  region = "ap-northeast-1"
  #Japan
}
provider "aws" {
  alias = "us-east-1"
  region = "us-east-1" 
  #NewYork
}
provider "aws" {
  alias = "eu-west-2"
  region = "eu-west-2"
  #London
}
provider "aws" {
  alias = "sa-east-1"
  region = "sa-east-1" 
  #Brazil
}
provider "aws" {
  alias = "ap-southeast-2"
  region = "ap-southeast-2" 
  #Sydney
}
provider "aws" {
  alias = "ap-east-1"
  region = "ap-east-1" 
  #HongKong
}
provider "aws" {
  alias = "us-west-1"
  region = "us-west-1" 
  #Cali
}
################################################################################
# Modules and Infrastructure
################################################################################
# vpc
module "vpc_japan" {
  source             = "./modules/vpc"
  region             = "ap-northeast-1"
  cidr_block         = "10.150.0.0/16"
  name               = "app1"
  service            = "J-Tele-Doctor"
  subnet1_cidr_block = "10.150.1.0/24"
  subnet2_cidr_block = "10.150.3.0/24"
  subnet3_cidr_block = "10.150.11.0/24"
  subnet4_cidr_block = "10.150.13.0/24"
  AZ1                = "ap-northeast-1a"
  AZ2                = "ap-northeast-1c"
  TGW_id             = module.TGW_japan.TGW_id
}
resource "aws_subnet" "private-ap-northeast-1c-2" {
  vpc_id                  = module.vpc_japan.vpc_id
  cidr_block              = "10.150.23.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = {
    Name    = "app1-private-subnet1-2"
    Service = "J-Tele-Doctor"
  }
}
resource "aws_subnet" "private-ap-northeast-1d" {
  vpc_id                  = module.vpc_japan.vpc_id
  cidr_block              = "10.150.14.0/24"
  availability_zone       = "ap-northeast-1d"
  map_public_ip_on_launch = false

  tags = {
    Name    = "app1-private-subnet3"
    Service = "J-Tele-Doctor"
  }
}
# infrastructure
module "infrastructure_japan" {
  source             = "./modules/infrastructure"
  region             = "ap-northeast-1"
  vpc_id             = module.vpc_japan.vpc_id
  name               = "app1"
  service            = "J-Tele-Doctor"
  key_name           = "key"
  subnet1            = module.vpc_japan.subnet1_id
  subnet2            = module.vpc_japan.subnet2_id
  subnet3            = module.vpc_japan.subnet3_id 
  subnet4            = module.vpc_japan.subnet4_id
  syslog_ip          = aws_instance.syslog-server.private_ip
  dependency_trigger = aws_route53_record.syslog.id #Null resource is linked to the private hosted zone. Child modules launch template depends on this.
}
resource "aws_security_group" "Aurora-japan" {
  name        = "Aurora-sg"
  description = "Aurora-sg"
  vpc_id      = module.vpc_japan.vpc_id

  ingress {
    description = "Allow Aurora traffic"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "ssh_syslog-japan" {
  name        = "app1-ssh-syslog"
  description = "app1-ssh-syslog"
  vpc_id      = module.vpc_japan.vpc_id

  ingress { 
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow syslog traffic (UDP)"
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow syslog traffic (TCP)"
    from_port   = 514
    to_port     = 514
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "app1-ssh-syslog"
  }
}
resource "aws_security_group" "Endpoint-Japan" {
  name        = "app1-endpoint-sg"
  description = "Endpoint security group allowing SSH traffic"
  vpc_id      = module.vpc_japan.vpc_id


  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "app1-endpoint-sg"
    Service = "J-Tele-Doctor"
  }
}
# TGW
module "TGW_japan" {
  source          = "./modules/TGW"
  region          = "ap-northeast-1"
  vpc_id          = module.vpc_japan.vpc_id
  name_TGW_Region = "Japan"
  subnet3_id      = module.vpc_japan.subnet3_id
  subnet4_id      = module.vpc_japan.subnet4_id
}
# NewYork
module "vpc_NewYork" {
  source             = "./modules/vpc"
  region             = "us-east-1"
  cidr_block         = "10.151.0.0/16"
  name               = "app1"
  service            = "J-Tele-Doctor"
  subnet1_cidr_block = "10.151.1.0/24"
  subnet2_cidr_block = "10.151.2.0/24"
  subnet3_cidr_block = "10.151.11.0/24"
  subnet4_cidr_block = "10.151.12.0/24"
  AZ1                = "us-east-1a"
  AZ2                = "us-east-1b"
  TGW_id             = module.TGW_NewYork.TGW_id
}
module "infrastructure_NewYork" {
  source                    = "./modules/infrastructure"
  region                    =  "us-east-1"
  vpc_id                    = module.vpc_NewYork.vpc_id
  name                      = "app1"
  service                   = "J-Tele-Doctor"
  key_name                  = "key"
  subnet1                   = module.vpc_NewYork.subnet1_id
  subnet2                   = module.vpc_NewYork.subnet2_id
  subnet3                   = module.vpc_NewYork.subnet3_id 
  subnet4                   = module.vpc_NewYork.subnet4_id
  syslog_ip                 = aws_instance.syslog-server.private_ip
  dependency_trigger        = aws_route53_record.syslog.id
}
module "TGW_NewYork" {
  source          = "./modules/TGW"
  region          = "us-east-1"
  vpc_id          = module.vpc_NewYork.vpc_id
  name_TGW_Region = "NewYork"
  subnet3_id      = module.vpc_NewYork.subnet3_id
  subnet4_id      = module.vpc_NewYork.subnet4_id
}
# London
module "vpc_London" {
  source             = "./modules/vpc"
  region             = "eu-west-2"
  cidr_block         = "10.152.0.0/16"
  name               = "app1"
  service            = "J-Tele-Doctor"
  subnet1_cidr_block = "10.152.1.0/24"
  subnet2_cidr_block = "10.152.2.0/24"
  subnet3_cidr_block = "10.152.11.0/24"
  subnet4_cidr_block = "10.152.12.0/24"
  AZ1                = "eu-west-2a"
  AZ2                = "eu-west-2b"
  TGW_id             = module.TGW_London.TGW_id
}
module "infrastructure_London" {
  source                    = "./modules/infrastructure"
  region                    =  "eu-west-2"
  vpc_id                    = module.vpc_London.vpc_id
  name                      = "app1"
  service                   = "J-Tele-Doctor"
  key_name                  = "key"
  subnet1                   = module.vpc_London.subnet1_id
  subnet2                   = module.vpc_London.subnet2_id
  subnet3                   = module.vpc_London.subnet3_id 
  subnet4                   = module.vpc_London.subnet4_id
  syslog_ip                 = aws_instance.syslog-server.private_ip
  dependency_trigger        = aws_route53_record.syslog.id
}
module "TGW_London" {
  source          = "./modules/TGW"
  region          = "eu-west-2"
  vpc_id          = module.vpc_London.vpc_id
  name_TGW_Region = "London"
  subnet3_id      = module.vpc_London.subnet3_id
  subnet4_id      = module.vpc_London.subnet4_id
}
# Brazil
module "vpc_Brazil" {
  source             = "./modules/vpc"
  region             = "sa-east-1"
  cidr_block         = "10.153.0.0/16"
  name               = "app1"
  service            = "J-Tele-Doctor"
  subnet1_cidr_block = "10.153.1.0/24"
  subnet2_cidr_block = "10.153.2.0/24"
  subnet3_cidr_block = "10.153.11.0/24"
  subnet4_cidr_block = "10.153.12.0/24"
  AZ1                = "sa-east-1a"
  AZ2                = "sa-east-1b"
  TGW_id             = module.TGW_Brazil.TGW_id
}
module "infrastructure_Brazil" {
  source                    = "./modules/infrastructure"
  region                    =  "sa-east-1"
  vpc_id                    = module.vpc_Brazil.vpc_id
  name                      = "app1"
  service                   = "J-Tele-Doctor"
  key_name                  = "key"
  subnet1                   = module.vpc_Brazil.subnet1_id
  subnet2                   = module.vpc_Brazil.subnet2_id
  subnet3                   = module.vpc_Brazil.subnet3_id 
  subnet4                   = module.vpc_Brazil.subnet4_id
  syslog_ip                 = aws_instance.syslog-server.private_ip
  dependency_trigger        = aws_route53_record.syslog.id
}
module "TGW_Brazil" {
  source          = "./modules/TGW"
  region          = "sa-east-1"
  vpc_id          = module.vpc_Brazil.vpc_id
  name_TGW_Region = "Brazil"
  subnet3_id      = module.vpc_Brazil.subnet3_id
  subnet4_id      = module.vpc_Brazil.subnet4_id
}
# Sydney
module "vpc_Sydney" {
  source             = "./modules/vpc"
  region             = "ap-southeast-2"
  cidr_block         = "10.154.0.0/16"
  name               = "app1"
  service            = "J-Tele-Doctor"
  subnet1_cidr_block = "10.154.1.0/24"
  subnet2_cidr_block = "10.154.2.0/24"
  subnet3_cidr_block = "10.154.11.0/24"
  subnet4_cidr_block = "10.154.12.0/24"
  AZ1                = "ap-southeast-2a"
  AZ2                = "ap-southeast-2b"
  TGW_id             = module.TGW_Sydney.TGW_id
}
module "infrastructure_Sydney" {
  source                    = "./modules/infrastructure"
  region                    =  "ap-southeast-2"
  vpc_id                    = module.vpc_Sydney.vpc_id
  name                      = "app1"
  service                   = "J-Tele-Doctor"
  key_name                  = "key"
  subnet1                   = module.vpc_Sydney.subnet1_id
  subnet2                   = module.vpc_Sydney.subnet2_id
  subnet3                   = module.vpc_Sydney.subnet3_id 
  subnet4                   = module.vpc_Sydney.subnet4_id
  syslog_ip                 = aws_instance.syslog-server.private_ip
  dependency_trigger        = aws_route53_record.syslog.id
}
module "TGW_Sydney" {
  source          = "./modules/TGW"
  region          = "ap-southeast-2"
  vpc_id          = module.vpc_Sydney.vpc_id
  name_TGW_Region = "Sydney"
  subnet3_id      = module.vpc_Sydney.subnet3_id
  subnet4_id      = module.vpc_Sydney.subnet4_id
}
# HongKong
module "vpc_HongKong" {
  source             = "./modules/vpc"
  region             = "ap-east-1"
  cidr_block         = "10.155.0.0/16"
  name               = "app1"
  service            = "J-Tele-Doctor"
  subnet1_cidr_block = "10.155.1.0/24"
  subnet2_cidr_block = "10.155.2.0/24"
  subnet3_cidr_block = "10.155.11.0/24"
  subnet4_cidr_block = "10.155.12.0/24"
  AZ1                = "ap-east-1a"
  AZ2                = "ap-east-1b"
  TGW_id             = module.TGW_HongKong.TGW_id
}
module "infrastructure_HongKong" {
  source                    = "./modules/infrastructure"
  region                    =  "ap-east-1"
  vpc_id                    = module.vpc_HongKong.vpc_id
  name                      = "app1"
  service                   = "J-Tele-Doctor"
  key_name                  = "key"
  subnet1                   = module.vpc_HongKong.subnet1_id
  subnet2                   = module.vpc_HongKong.subnet2_id
  subnet3                   = module.vpc_HongKong.subnet3_id 
  subnet4                   = module.vpc_HongKong.subnet4_id
  syslog_ip                 = aws_instance.syslog-server.private_ip
  dependency_trigger        = aws_route53_record.syslog.id
}
module "TGW_HongKong" {
  source          = "./modules/TGW"
  region          = "ap-east-1"
  vpc_id          = module.vpc_HongKong.vpc_id
  name_TGW_Region = "HongKong"
  subnet3_id      = module.vpc_HongKong.subnet3_id
  subnet4_id      = module.vpc_HongKong.subnet4_id
}
# Cali
module "vpc_Cali" {
  source             = "./modules/vpc"
  region             = "us-west-1"
  cidr_block         = "10.156.0.0/16"
  name               = "app1"
  service            = "J-Tele-Doctor"
  subnet1_cidr_block = "10.156.2.0/24"
  subnet2_cidr_block = "10.156.3.0/24"
  subnet3_cidr_block = "10.156.12.0/24"
  subnet4_cidr_block = "10.156.13.0/24"
  AZ1                = "us-west-1b"
  AZ2                = "us-west-1c"
  TGW_id             = module.TGW_Cali.TGW_id
}
module "infrastructure_Cali" {
  source                    = "./modules/infrastructure"
  region                    =  "us-west-1"
  vpc_id                    = module.vpc_Cali.vpc_id
  name                      = "app1"
  service                   = "J-Tele-Doctor"
  key_name                  = "key"
  subnet1                   = module.vpc_Cali.subnet1_id
  subnet2                   = module.vpc_Cali.subnet2_id
  subnet3                   = module.vpc_Cali.subnet3_id 
  subnet4                   = module.vpc_Cali.subnet4_id
  syslog_ip                 = aws_instance.syslog-server.private_ip
  dependency_trigger        = aws_route53_record.syslog.id
}
module "TGW_Cali" {
  source          = "./modules/TGW"
  region          = "us-west-1"
  vpc_id          = module.vpc_Cali.vpc_id
  name_TGW_Region = "Cali"
  subnet3_id      = module.vpc_Cali.subnet3_id
  subnet4_id      = module.vpc_Cali.subnet4_id
}
################################################################################
# TGW Peer Requestor
################################################################################
#japan to NewYork
resource "aws_ec2_transit_gateway_peering_attachment" "Japan_NewYork_Peer_Request" { #peer
  transit_gateway_id        = module.TGW_japan.TGW_id
  peer_transit_gateway_id   = module.TGW_NewYork.TGW_id
  peer_region               = "us-east-1"
  tags = {
    Name = "Japan-NewYork-Peer-Request"
  }
}
#japan to London
resource "aws_ec2_transit_gateway_peering_attachment" "Japan_London_Peer_Request" { #peer
  transit_gateway_id        = module.TGW_japan.TGW_id
  peer_transit_gateway_id   = module.TGW_London.TGW_id
  peer_region               = "eu-west-2"
  tags = {
    Name = "Japan-London-Peer-Request"
  }
}
#japan to Brazil
resource "aws_ec2_transit_gateway_peering_attachment" "Japan_Brazil_Peer_Request" { #peer
  transit_gateway_id        = module.TGW_japan.TGW_id
  peer_transit_gateway_id   = module.TGW_Brazil.TGW_id
  peer_region               = "sa-east-1"
  tags = {
    Name = "Japan-Brazil-Peer-Request"
  }
}
#japan to Sydney
resource "aws_ec2_transit_gateway_peering_attachment" "Japan_Sydney_Peer_Request" { #peer
  transit_gateway_id        = module.TGW_japan.TGW_id
  peer_transit_gateway_id   = module.TGW_Sydney.TGW_id
  peer_region               = "ap-southeast-2"
  tags = {
    Name = "Japan-Sydney-Peer-Request"
  }
}
#japan to HongKong
resource "aws_ec2_transit_gateway_peering_attachment" "Japan_HongKong_Peer_Request" { #peer
  transit_gateway_id        = module.TGW_japan.TGW_id
  peer_transit_gateway_id   = module.TGW_HongKong.TGW_id
  peer_region               = "ap-east-1"
  tags = {
    Name = "Japan-HongKong-Peer-Request"
  }
}
#japan to Cali
resource "aws_ec2_transit_gateway_peering_attachment" "Japan_Cali_Peer_Request" { #peer
  transit_gateway_id        = module.TGW_japan.TGW_id
  peer_transit_gateway_id   = module.TGW_Cali.TGW_id
  peer_region               = "us-west-1"
  tags = {
    Name = "Japan-Cali-Peer-Request"
  }
}
################################################################################
# TGW Peer Acceptor
################################################################################
#NewYork
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "NewYork_Japan_Peer_Accepter" { #accept peer
  provider                      = aws.us-east-1
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.Japan_NewYork_Peer_Request.id
  tags = {
    Name = "NewYork-Japan-Peer-Accepter"
  }
}
#London
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "London_Japan_Peer_Accepter" { #accept peer
  provider                      = aws.eu-west-2
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.Japan_London_Peer_Request.id
  tags = {
    Name = "London-Japan-Peer-Accepter"
  }
}
#Brazil
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "Brazil_Japan_Peer_Accepter" { #accept peer
  provider                      = aws.sa-east-1
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.Japan_Brazil_Peer_Request.id
  tags = {
    Name = "Brazil-Japan-Peer-Accepter"
  }
}
#Sydney
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "Sydney_Japan_Peer_Accepter" { #accept peer
  provider                      = aws.ap-southeast-2
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.Japan_Sydney_Peer_Request.id
  tags = {
    Name = "Sydney-Japan-Peer-Accepter"
  }
}
#HongKong
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "HongKong_Japan_Peer_Accepter" { #accept peer
  provider                      = aws.ap-east-1
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.Japan_HongKong_Peer_Request.id
  tags = {
    Name = "HongKong-Japan-Peer-Accepter"
  }
}
#Cali
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "Cali_Japan_Peer_Accepter" { #accept peer
  provider                      = aws.us-west-1
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.Japan_Cali_Peer_Request.id
  tags = {
    Name = "Cali-Japan-Peer-Accepter"
  }
}
################################################################################
# Associate TGW Peers to TGW Route-table 
################################################################################
#Japan to NewYork TGW Peer Association
resource "aws_ec2_transit_gateway_route_table_association" "Japan_to_NewYork_TGW1_Peer_Association" { #Associates Japan-NewYork-TGW-Peer to Japan-TGW-Route-Table
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.NewYork_Japan_Peer_Accepter.id #ensures the peer is accepted before association
  transit_gateway_route_table_id = module.TGW_japan.TGW_route_table_id
  replace_existing_association   = true #removes default TGW-Route-Table-Association so you can associate with the TGW-Route-Table specified in your code
}
#Japan to London TGW Peer Association
resource "aws_ec2_transit_gateway_route_table_association" "Japan_to_London_TGW1_Peer_Association" { #Associates Japan-London-TGW-Peer to Japan-TGW-Route-Table
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.London_Japan_Peer_Accepter.id #ensures the peer is accepted before association
  transit_gateway_route_table_id = module.TGW_japan.TGW_route_table_id
  replace_existing_association   = true #removes default TGW-Route-Table-Association so you can associate with the TGW-Route-Table specified in your code
}
#Japan to Brazil TGW Peer Association
resource "aws_ec2_transit_gateway_route_table_association" "Japan_to_Brazil_TGW1_Peer_Association" { #Associates Japan-Brazil-TGW-Peer to Japan-TGW-Route-Table
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Brazil_Japan_Peer_Accepter.id #ensures the peer is accepted before association
  transit_gateway_route_table_id = module.TGW_japan.TGW_route_table_id
  replace_existing_association   = true #removes default TGW-Route-Table-Association so you can associate with the TGW-Route-Table specified in your code
}
#Japan to Sydney TGW Peer Association
resource "aws_ec2_transit_gateway_route_table_association" "Japan_to_Sydney_TGW1_Peer_Association" { #Associates Japan-Sydney-TGW-Peer to Japan-TGW-Route-Table
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Sydney_Japan_Peer_Accepter.id #ensures the peer is accepted before association
  transit_gateway_route_table_id = module.TGW_japan.TGW_route_table_id
  replace_existing_association   = true #removes default TGW-Route-Table-Association so you can associate with the TGW-Route-Table specified in your code
}
#Japan to HongKong TGW Peer Association
resource "aws_ec2_transit_gateway_route_table_association" "Japan_to_HongKong_TGW1_Peer_Association" { #Associates Japan-HongKong-TGW-Peer to Japan-TGW-Route-Table
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.HongKong_Japan_Peer_Accepter.id #ensures the peer is accepted before association
  transit_gateway_route_table_id = module.TGW_japan.TGW_route_table_id
  replace_existing_association   = true #removes default TGW-Route-Table-Association so you can associate with the TGW-Route-Table specified in your code
}
#Japan to Cali TGW Peer Association
resource "aws_ec2_transit_gateway_route_table_association" "Japan_to_Cali_TGW1_Peer_Association" { #Associates Japan-Cali-TGW-Peer to Japan-TGW-Route-Table
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Cali_Japan_Peer_Accepter.id #ensures the peer is accepted before association
  transit_gateway_route_table_id = module.TGW_japan.TGW_route_table_id
  replace_existing_association   = true #removes default TGW-Route-Table-Association so you can associate with the TGW-Route-Table specified in your code
}
#NewYork to Japan TGW Peer Association
resource "aws_ec2_transit_gateway_route_table_association" "NewYork-TGW1_Peer_Association" { #Associates NewYork-Japan-TGW-Peer to NewYork-TGW-Route-Table
  provider = aws.us-east-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.NewYork_Japan_Peer_Accepter.id #ensures the peer is accepted before association
  transit_gateway_route_table_id = module.TGW_NewYork.TGW_route_table_id
  replace_existing_association   = true #removes default TGW-Route-Table-Association so you can associate with the TGW-Route-Table specified in your code
}
#London to Japan TGW Peer Association
resource "aws_ec2_transit_gateway_route_table_association" "London-TGW1_Peer_Association" { #Associates London-Japan-TGW-Peer to London-TGW-Route-Table
  provider = aws.eu-west-2
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.London_Japan_Peer_Accepter.id #ensures the peer is accepted before association
  transit_gateway_route_table_id = module.TGW_London.TGW_route_table_id
  replace_existing_association   = true #removes default TGW-Route-Table-Association so you can associate with the TGW-Route-Table specified in your code
}
#Brazil to Japan TGW Peer Association
resource "aws_ec2_transit_gateway_route_table_association" "Brazil-TGW1_Peer_Association" { #Associates Brazil-Japan-TGW-Peer to Brazil-TGW-Route-Table
  provider = aws.sa-east-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Brazil_Japan_Peer_Accepter.id #ensures the peer is accepted before association
  transit_gateway_route_table_id = module.TGW_Brazil.TGW_route_table_id
  replace_existing_association   = true #removes default TGW-Route-Table-Association so you can associate with the TGW-Route-Table specified in your code
}
#Sydney to Japan TGW Peer Association
resource "aws_ec2_transit_gateway_route_table_association" "Sydney-TGW1_Peer_Association" { #Associates Sydney-Japan-TGW-Peer to Sydney-TGW-Route-Table
  provider = aws.ap-southeast-2
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Sydney_Japan_Peer_Accepter.id #ensures the peer is accepted before association
  transit_gateway_route_table_id = module.TGW_Sydney.TGW_route_table_id
  replace_existing_association   = true #removes default TGW-Route-Table-Association so you can associate with the TGW-Route-Table specified in your code
}
#HongKong to Japan TGW Peer Association
resource "aws_ec2_transit_gateway_route_table_association" "HongKong-TGW1_Peer_Association" { #Associates HongKong-Japan-TGW-Peer to HongKong-TGW-Route-Table
  provider = aws.ap-east-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.HongKong_Japan_Peer_Accepter.id #ensures the peer is accepted before association
  transit_gateway_route_table_id = module.TGW_HongKong.TGW_route_table_id
  replace_existing_association   = true #removes default TGW-Route-Table-Association so you can associate with the TGW-Route-Table specified in your code
}
#Cali to Japan TGW Peer Association
resource "aws_ec2_transit_gateway_route_table_association" "Cali-TGW1_Peer_Association" { #Associates Cali-Japan-TGW-Peer to Cali-TGW-Route-Table
  provider = aws.us-west-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Cali_Japan_Peer_Accepter.id #ensures the peer is accepted before association
  transit_gateway_route_table_id = module.TGW_Cali.TGW_route_table_id
  replace_existing_association   = true #removes default TGW-Route-Table-Association so you can associate with the TGW-Route-Table specified in your code
}
################################################################################
# Define route between TGW Peers inside the TGW Route-table 
################################################################################
#Japan to NewYork TGW Route
resource "aws_ec2_transit_gateway_route" "Japan_to_NewYork_Route" { #Route on TGW Japan -> to -> NewYork
  transit_gateway_route_table_id = module.TGW_japan.TGW_route_table_id
  destination_cidr_block         = "10.151.0.0/16"  # CIDR block of the VPC in us-east-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.NewYork_Japan_Peer_Accepter.id #ensures the peer is accepted before defining route
}
#Japan to London TGW Route
resource "aws_ec2_transit_gateway_route" "Japan_to_London_Route" { #Route on TGW Japan -> to -> London
  transit_gateway_route_table_id = module.TGW_japan.TGW_route_table_id
  destination_cidr_block         = "10.152.0.0/16"  # CIDR block of the VPC in us-east-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.London_Japan_Peer_Accepter.id #ensures the peer is accepted before defining route
}
#Japan to Brazil TGW Route
resource "aws_ec2_transit_gateway_route" "Japan_to_Brazil_Route" { #Route on TGW Japan -> to -> Brazil
  transit_gateway_route_table_id = module.TGW_japan.TGW_route_table_id
  destination_cidr_block         = "10.153.0.0/16"  # CIDR block of the VPC in us-east-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Brazil_Japan_Peer_Accepter.id #ensures the peer is accepted before defining route
}
#Japan to Sydney TGW Route
resource "aws_ec2_transit_gateway_route" "Japan_to_Sydney_Route" { #Route on TGW Japan -> to -> Sydney
  transit_gateway_route_table_id = module.TGW_japan.TGW_route_table_id
  destination_cidr_block         = "10.154.0.0/16"  # CIDR block of the VPC in us-east-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Sydney_Japan_Peer_Accepter.id #ensures the peer is accepted before defining route
}
#Japan to HongKong TGW Route
resource "aws_ec2_transit_gateway_route" "Japan_to_HongKong_Route" { #Route on TGW Japan -> to -> HongKong
  transit_gateway_route_table_id = module.TGW_japan.TGW_route_table_id
  destination_cidr_block         = "10.155.0.0/16"  # CIDR block of the VPC in us-east-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.HongKong_Japan_Peer_Accepter.id #ensures the peer is accepted before defining route
}
#Japan to Cali TGW Route
resource "aws_ec2_transit_gateway_route" "Japan_to_Cali_Route" { #Route on TGW Japan -> to -> Cali
  transit_gateway_route_table_id = module.TGW_japan.TGW_route_table_id
  destination_cidr_block         = "10.156.0.0/16"  # CIDR block of the VPC in us-east-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Cali_Japan_Peer_Accepter.id #ensures the peer is accepted before defining route
}
#NewYork to Japan TGW Route
resource "aws_ec2_transit_gateway_route" "NewYork_to_Japan_Route" { #Route on TGW NewYork -> to -> Japan
  provider = aws.us-east-1
  transit_gateway_route_table_id = module.TGW_NewYork.TGW_route_table_id
  destination_cidr_block         = "10.150.0.0/16"  # CIDR block of the VPC in ap-northeast-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.NewYork_Japan_Peer_Accepter.id #ensures the peer is accepted before defining route
}
#London to Japan TGW Route
resource "aws_ec2_transit_gateway_route" "London_to_Japan_Route" { #Route on TGW London -> to -> Japan
  provider = aws.eu-west-2
  transit_gateway_route_table_id = module.TGW_London.TGW_route_table_id
  destination_cidr_block         = "10.150.0.0/16"  # CIDR block of the VPC in ap-northeast-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.London_Japan_Peer_Accepter.id #ensures the peer is accepted before defining route
}
#Brazil to Japan TGW Route
resource "aws_ec2_transit_gateway_route" "Brazil_to_Japan_Route" { #Route on TGW Brazil -> to -> Japan
  provider = aws.sa-east-1
  transit_gateway_route_table_id = module.TGW_Brazil.TGW_route_table_id
  destination_cidr_block         = "10.150.0.0/16"  # CIDR block of the VPC in ap-northeast-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Brazil_Japan_Peer_Accepter.id #ensures the peer is accepted before defining route
}
#Sydney to Japan TGW Route
resource "aws_ec2_transit_gateway_route" "Sydney_to_Japan_Route" { #Route on TGW Sydney -> to -> Japan
  provider = aws.ap-southeast-2
  transit_gateway_route_table_id = module.TGW_Sydney.TGW_route_table_id
  destination_cidr_block         = "10.150.0.0/16"  # CIDR block of the VPC in ap-northeast-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Sydney_Japan_Peer_Accepter.id #ensures the peer is accepted before defining route
}
#HongKong to Japan TGW Route
resource "aws_ec2_transit_gateway_route" "HongKong_to_Japan_Route" { #Route on TGW HongKong -> to -> Japan
  provider = aws.ap-east-1
  transit_gateway_route_table_id = module.TGW_HongKong.TGW_route_table_id
  destination_cidr_block         = "10.150.0.0/16"  # CIDR block of the VPC in ap-northeast-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.HongKong_Japan_Peer_Accepter.id #ensures the peer is accepted before defining route
}
#Cali to Japan TGW Route
resource "aws_ec2_transit_gateway_route" "Cali_to_Japan_Route" { #Route on TGW Cali -> to -> Japan
  provider = aws.us-west-1
  transit_gateway_route_table_id = module.TGW_Cali.TGW_route_table_id
  destination_cidr_block         = "10.150.0.0/16"  # CIDR block of the VPC in ap-northeast-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Cali_Japan_Peer_Accepter.id #ensures the peer is accepted before defining route
}
################################################################################
# Syslog server and its' associated Endpoint
################################################################################
resource "aws_ec2_instance_connect_endpoint" "Japan_Endpoint" {
  subnet_id          = module.vpc_japan.subnet1_id
  security_group_ids = [aws_security_group.Endpoint-Japan.id]
}

resource "aws_instance" "syslog-server" { #SYSLOG server in private Zone. Logs Agents TCP/UDP port 514 traffic. View traffic via "tail -f /var/log/messages"
  ami                     = module.infrastructure_japan.ami_id
  instance_type           = "t3.micro"
  subnet_id               = module.vpc_japan.subnet3_id
  vpc_security_group_ids  = [aws_security_group.ssh_syslog-japan.id]
  user_data = base64encode(<<-EOF
#!/bin/bash
# Install and configure rsyslog
# Install rsyslog
yum install -y rsyslog

# Start and enable rsyslog
systemctl start rsyslog
systemctl enable rsyslog

# Configure rsyslog to accept remote logs
echo "
# Provides TCP syslog reception
module(load=\"imtcp\")
input(type=\"imtcp\" port=\"514\")

# Provides UDP syslog reception
module(load=\"imudp\")
input(type=\"imudp\" port=\"514\")
" >> /etc/rsyslog.conf

# Restart rsyslog to apply changes
systemctl restart rsyslog

 EOF
  )
user_data_replace_on_change = true
lifecycle { #new instances are created before the old ones are destroyed. This helps maintain continuity without causing a temporary downtime.
  create_before_destroy = true 
  }
  provisioner "local-exec" { #waits 60 seconds after the instance initializes; this is for the CloudWatch Alarm + Health Check + Route 53 Failover routing dependency chain.
  command = "sleep 60" 
  } 
tags = {
  Name = "syslog-server"
  }

}

resource "aws_instance" "syslog-server2" { #SYSLOG server in private Zone. Logs Agents TCP/UDP port 514 traffic. View traffic via "tail -f /var/log/messages"
  ami                     = module.infrastructure_japan.ami_id
  instance_type           = "t3.micro"
  subnet_id               = module.vpc_japan.subnet4_id
  vpc_security_group_ids  = [aws_security_group.ssh_syslog-japan.id]
  user_data = base64encode(<<-EOF
#!/bin/bash
# Install and configure rsyslog
# Install rsyslog
yum install -y rsyslog

# Start and enable rsyslog
systemctl start rsyslog
systemctl enable rsyslog

# Configure rsyslog to accept remote logs
echo "
# Provides TCP syslog reception
module(load=\"imtcp\")
input(type=\"imtcp\" port=\"514\")

# Provides UDP syslog reception
module(load=\"imudp\")
input(type=\"imudp\" port=\"514\")
" >> /etc/rsyslog.conf

# Restart rsyslog to apply changes
systemctl restart rsyslog

 EOF
  )
user_data_replace_on_change = true
lifecycle { #new instances are created before the old ones are destroyed. This helps maintain continuity without causing a temporary downtime.
  create_before_destroy = true 
  }
tags = {
  Name = "syslog-server2"
  }

}





