#VPC
resource "aws_vpc" "gogo" {
  cidr_block = "11.0.0.0/16"

  tags = {
    Name = "gogo_vpc"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "gogo_gw" {
  vpc_id = "${aws_vpc.gogo.id}"

  tags = {
    Name = "gogoGW"
  }
}

resource "aws_security_group" "gogo_SG" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.gogo.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#Priv. subnet1
resource "aws_subnet" "gogo_priv1" {
  cidr_block = "11.0.1.0/24"
  vpc_id     = "${aws_vpc.gogo.id}"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "gogo_priv1"
  }
}

#Priv. subnet2
resource "aws_subnet" "gogo_priv2" {
  cidr_block = "11.0.2.0/24"
  vpc_id     = "${aws_vpc.gogo.id}"
  availability_zone = "eu-central-1c"
  tags = {
    Name = "gogo_priv2"
  }
}

#Pub. subnet1
resource "aws_subnet" "gogo_pub1" {
  cidr_block = "11.0.3.0/24"
  vpc_id     = "${aws_vpc.gogo.id}"
  availability_zone = "eu-central-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "gogo_pub1"
  }
}

#Priv. subnet2
resource "aws_subnet" "gogo_pub2" {
  cidr_block = "11.0.4.0/24"
  vpc_id     = "${aws_vpc.gogo.id}"
  availability_zone = "eu-central-1c"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "gogo_pub2"
  }
}

#Public route table
resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.gogo.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gogo_gw.id}"
  }

  tags = {
    Name = "gogo_pub"
  }
}

#Route association 
resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.gogo_pub1.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.gogo_pub2.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}
