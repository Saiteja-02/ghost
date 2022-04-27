data "aws_availability_zones" "available" {
  state = "available"
  exclude_names = ["ap-south-1c"]
}

resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "ghost_vpc"
  }
}

/*public  subnet*/

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  count = 2
  cidr_block = cidrsubnet(var.cidr_block, 2, count.index)
  availability_zone = element(data.aws_availability_zones.available.names.*, count.index)
  tags = {
    Name = "${var.key}-public_subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "internet_gw" {

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.key}-internet_gw"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count = 2
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.public_route_table.*.id, count.index)
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  count = 2
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_internet_gateway.internet_gw.*.id,count.index)
  }
  tags = {
    Name = "${var.key}-public_rt-${count.index}"
  }
}

/*private  subnet*/

resource "aws_subnet" "private_subnet" {
  count = 2
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 2, count.index+2)
  availability_zone = element(data.aws_availability_zones.available.names.*, count.index)
  tags = {
    Name = "${var.key}-public_subnet-${count.index}"
  }
}

resource "aws_eip" "eip" {
  count    = 2
  vpc      = true
}

resource "aws_nat_gateway" "nat" {
  count   = 2
  allocation_id = element(aws_eip.eip.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)

  tags = {
    Name = "${var.key}-NAT gw-${count.index}"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count = 2
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
}

resource "aws_route_table" "private_route_table" {
  count = 2
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }
  tags = {
    Name = "${var.key}-private_rt"
  }
}

/* Security groups */

resource "aws_security_group" "public_sg" {
  name        = "${var.key}-public_sg"
  description = "Public SG 80,443 (internet facing-load balancer)"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "traffic from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "traffic from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups   = []
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.key}-public-sg"
  }
}

resource "aws_security_group" "private_sg" {
  name        = "${var.key}-private_sg"
  description = "Private SG 80,443"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "traffic from alb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }
  ingress {
    description = "traffic from alb"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups = []
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.key}-public-sg"
  }
}


resource "aws_security_group" "db_sg" {
  name        = "${var.key}-db_sg"
  description = "db sg 80,443"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "traffic from private subnet (ec2-port 80)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.private_sg.id]
  }
  ingress {
    description = "traffic from private subnet (ec2-port 443)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.private_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups  = [aws_security_group.private_sg.id]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.key}-public-sg"
  }
}




/* Network ACL public subnet */
/*  
data "aws_subnet_ids" "vpc_id" {
  vpc_id = aws_vpc.vpc.id
}


resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  count = 2
  cidr_block = cidrsubnet(var.cidr_block, 2, count.index)

  tags = {
    count = 2
    Name = "${var.key}-public_subnet-${count.index}"
  }
} 


resource "aws_network_acl" "network_acl" {
  vpc_id = aws_vpc.vpc.id
  count = 2
  subnet_ids = [element(aws_subnet.public_subnet.*.id, count.index)]

  dynamic egress {
    for_each = var.nacl
    iterator = port
    content{
    protocol   = lookup({port.value=443?"https":"http", port.value=80?"http":"https"},port.value,"https")
    rule_no    = 100
    action     = "allow"
    cidr_block = lookup({cidrsubnet(var.cidr_block, 2, count.index)=cidrsubnet(var.cidr_block, 2, count.index+2)}, cidrsubnet(var.cidr_block, 2, count.index))
    from_port  = port.value
    to_port    = port.value
    }
    
  }

  dynamic ingress{
    for_each = var.nacl
    iterator = port
    content{
    protocol   = lookup({port.value=443?"https":"http", port.value=80?"http":"https"},port.value,"https")
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = port.value
    to_port    = port.value    
  } 
  }

  tags = {
    Name = "public_nacl"
  }
}
 */
