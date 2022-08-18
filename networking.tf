

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "gitlabiac_vpc" {
  count                = local.creat_vpc ? 1 : 0
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "${var.component_name}_gitlabiac"
  }
}

resource "aws_internet_gateway" "igw" {
  count  = local.creat_vpc ? 1 : 0
  vpc_id = local.vpc_id

}
resource "aws_subnet" "public_subnet" {
  count                   = local.creat_vpc ? length(var.pub_subnetcidr) : 0
  vpc_id                  = local.vpc_id
  cidr_block              = var.pub_subnetcidr[count.index]
  availability_zone       = element(local.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public-subnet-$element({local.azs, count.index})"
  }
}

resource "aws_subnet" "db_subnet" {
  count             = local.creat_vpc ? length(var.db_subnetcidr) : 0
  vpc_id            = local.vpc_id
  cidr_block        = var.db_subnetcidr[count.index]
  availability_zone = element(local.azs, count.index)

  tags = {
    "Name" = "db_subnet-${element(local.azs, count.index)}"
  }

}
# creating routes
resource "aws_route_table" "route_table" {
  count = local.creat_vpc ? length(var.pub_subnetcidr) : 0

  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }

}
#route table association
resource "aws_route_table_association" "route_table_ass" {
  count = local.creat_vpc ? length(var.pub_subnetcidr) : 0

  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.route_table[0].id
}

resource "aws_default_route_table" "default_route" {
  count = local.creat_vpc ? 1 : 0

  default_route_table_id = aws_vpc.gitlabiac_vpc[0].default_route_table_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_1[0].id
  }

}
resource "aws_eip" "eip" {
  count      = local.creat_vpc ? 1 : 0
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}
# creating nat gateway
resource "aws_nat_gateway" "ngw_1" {
  count         = local.creat_vpc ? 1 : 0
  allocation_id = aws_eip.eip[0].id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.igw]
}