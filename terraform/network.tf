resource "aws_vpc" "main" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-AWS"
  }
}

# subnet 1

resource "aws_subnet" "vpc_aws_private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.0.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "VPC-AWS-Private-1"
  }
}

resource "aws_route_table" "vpc_aws_private_subnet_1_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "VPC-AWS-Private-RT"
  }
}

resource "aws_route_table_association" "vpc_aws_private_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.vpc_aws_private_subnet_1.id
  route_table_id = aws_route_table.vpc_aws_private_subnet_1_route_table.id
}

resource "aws_route" "vpc_aws_private_subnet_1_route_to_vgw" {
  route_table_id         = aws_route_table.vpc_aws_private_subnet_1_route_table.id
  destination_cidr_block = "192.168.1.0/24"
  gateway_id             = aws_vpn_gateway.vpc_aws_vpn_gateway.id
}

resource "aws_route" "vpc_aws_private_subnet_1_route_to_nat" {
  route_table_id         = aws_route_table.vpc_aws_private_subnet_1_route_table.id
  destination_cidr_block = "192.168.1.2/32"
  nat_gateway_id         = aws_nat_gateway.aws_nat_gateway.id
}

# Subnet 2

resource "aws_subnet" "vpc_aws_private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.100.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "VPC-AWS-Private-2"
  }
}

resource "aws_route_table" "vpc_aws_private_subnet_2_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "VPC-AWS-Private-2-RT"
  }
}

resource "aws_route_table_association" "vpc_aws_private_subnet_2_route_table_association" {
  subnet_id      = aws_subnet.vpc_aws_private_subnet_2.id
  route_table_id = aws_route_table.vpc_aws_private_subnet_2_route_table.id
}

resource "aws_route" "vpc_aws_private_subnet_2_route_to_vgw" {
  route_table_id         = aws_route_table.vpc_aws_private_subnet_2_route_table.id
  destination_cidr_block = "192.168.1.2/32"
  gateway_id             = aws_vpn_gateway.vpc_aws_vpn_gateway.id
}

resource "aws_nat_gateway" "aws_nat_gateway" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.vpc_aws_private_subnet_2.id
  private_ip        = "10.10.100.100"
}

# VPN connection

resource "aws_vpn_gateway" "vpc_aws_vpn_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "VPC-AWS-VGW"
  }
}

resource "aws_customer_gateway" "home_cgw" {
  bgp_asn    = 65000
  ip_address = "125.198.73.133"
  type      = "ipsec.1"
  tags = { 
    Name = "HOME-CGW"
  }
}

resource "aws_vpn_connection" "home_vpn_connection" {
  vpn_gateway_id      = aws_vpn_gateway.vpc_aws_vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.home_cgw.id
  type                = "ipsec.1"
  static_routes_only  = true
  local_ipv4_network_cidr = "192.168.1.0/24"
  remote_ipv4_network_cidr = "10.10.0.0/16"
  tags = {
    Name = "HOME-VPN-Connection"
  }
  tunnel1_preshared_key = "test1234"
  tunnel1_ike_versions = ["ikev2"]
  tunnel1_phase1_dh_group_numbers = [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
  tunnel1_phase2_dh_group_numbers = [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase2_encryption_algorithms = ["AES256"]
  tunnel1_phase1_integrity_algorithms = ["SHA2-256", "SHA2-384", "SHA2-512"]
  tunnel1_phase2_integrity_algorithms = ["SHA2-256", "SHA2-384", "SHA2-512"]
  tunnel1_log_options {
    cloudwatch_log_options {
      log_enabled = false
      log_group_arn = aws_cloudwatch_log_group.home_vpn_log_group.arn
    }
  }
}

resource "aws_vpn_connection_route" "home_vpn_connection_route" {
  vpn_connection_id = aws_vpn_connection.home_vpn_connection.id
  destination_cidr_block = "192.168.1.0/24"
}

resource "aws_cloudwatch_log_group" "home_vpn_log_group" {
  name              = "/aws/aws-home-vpn"
  retention_in_days = 1
  tags = {
    Name = "HOME-VPN-Log-Group"
  }
}