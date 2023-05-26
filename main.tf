resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags       = merge (
      local.common_tags,
      { Name = "${var.env}-vpc" }
    )
}

resource "aws_vpc_peering_connection" "peer" {
  peer_owner_id = data.aws_caller_identity.current.account_id
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.main.id
  auto_accept   = true
  tags       = merge (
    local.common_tags,
    { Name = "${var.env}-peering" }
  )
}

resource "aws_route" "r" {
  route_table_id            = data.aws_vpc.default.main_route_table_id
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags       = merge (
    local.common_tags,
    { Name = "${var.env}-igw" }
  )
}

resource "aws_route" "nat_gw_route" {
  count                  = var.nat_gw ? 1 : 0
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gw_id
}

