output "vpc_ids" {
  description = "Map of VPC names to their IDs"
  value = {
    for name, vpc in aws_vpc.this :
    name => vpc.id
  }
}

output "public_subnet_ids" {
  description = "Map of public subnet names to their IDs"
  value = {
    for name, subnet in aws_subnet.this :
    name => subnet.id
    if subnet.map_public_ip_on_launch
  }
}

output "private_subnet_ids" {
  description = "Map of private subnet names to their IDs"
  value = {
    for name, subnet in aws_subnet.this :
    name => subnet.id
    if !subnet.map_public_ip_on_launch
  }
}

output "nat_gateway_ids" {
  description = "Map of NAT Gateway names to their public IPs"
  value = {
    for name, nat in aws_nat_gateway.this :
    name => nat.public_ip
  }
}

output "route_table_ids" {
  description = "Map of route table names to their IDs"
  value = {
    for name, route_table in aws_route_table.this :
    name => route_table.id
  }
}


output "vpc_endpoints" {
  description = "Map of VPC endpoint details"
  value = {
    for k, v in aws_vpc_endpoint.this : k => {
      id             = v.id
      arn            = v.arn
      state          = v.state
      service_name   = v.service_name
      prefix_list_id = v.prefix_list_id
    }
  }
}