resource "aws_vpc" "vpc_app" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc_app"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_app.id
  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "public_subnet" {
  count = 2
  vpc_id = aws_vpc.vpc_app.id
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = "${var.region}${count.index == 0 ? "a" : "b"}"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = 2
  vpc_id = aws_vpc.vpc_app.id
  cidr_block = "10.0.${count.index + 2}.0/24"
  availability_zone = "${var.region}${count.index == 0 ? "a" : "b"}"
  map_public_ip_on_launch = false
  tags = {
    Name = "private_subnet_${count.index}"
  }
}



resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_app.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count = 2
  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "elastic_ip" {
  count = 2
  vpc = true
  tags = {
    Name = "nat_eip_${count.index}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count = 2
  allocation_id = aws_eip.elastic_ip[count.index].id
  subnet_id = aws_subnet.public_subnet[count.index].id
  tags = {
    Name = "nat_gateway_${count.index}"
  }
}


resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.vpc_app.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }
  tags = {
    Name = "private_route_table_${count.index}"
  }
}


resource "aws_route_table_association" "private_route_table_association" {
  count = 2
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
