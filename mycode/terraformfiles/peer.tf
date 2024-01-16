resource "aws_vpc_peering_connection" "proj" {
  peer_owner_id = "586363011690"
  peer_vpc_id   = aws_vpc.dev.id
  vpc_id        = aws_vpc.prod.id
  peer_region   = "ap-south-1"
  auto_accept   = false
  tags = {
   Name = "Dev-Prod-Peering"
  }
}
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                   = aws.central
  vpc_peering_connection_id  = aws_vpc_peering_connection.proj.id
  auto_accept                = true
  tags = {
    Side = "Accepter"
  }
}

resource "aws_route" "dev-prod-1"{
 route_table_id = aws_route_table.dev-public-rt.id
 destination_cidr_block = "20.0.0.0/16"
 gateway_id = aws_vpc_peering_connection.proj.id
}
resource "aws_route" "dev-prod-2"{
 route_table_id = aws_route_table.dev-private-rt.id
 destination_cidr_block = "20.0.0.0/16"
 gateway_id = aws_vpc_peering_connection.proj.id
}
resource "aws_route" "prod-dev-1"{
 route_table_id = aws_route_table.prod-private-rt.id
 destination_cidr_block = "10.0.0.0/16"
 gateway_id = aws_vpc_peering_connection.proj.id
}
resource "aws_route" "prod-dev-2"{
 route_table_id = aws_route_table.prod-public-rt.id
 destination_cidr_block = "10.0.0.0/16"
 gateway_id = aws_vpc_peering_connection.proj.id
}
