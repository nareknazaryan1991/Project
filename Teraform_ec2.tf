# Region
provider "aws" {
  region = "us-west-1" 
}

# Create an EC2 instance
resource "aws_instance" "ec2-db" {

  ami                         = "ami-0781b2f5146911b9a"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.db_subnet.id
  vpc_security_group_ids      = [aws_security_group.db_vpc_security_group.id]
  associate_public_ip_address = true
  key_name                    = "narek-es2-2.4-key"
  tags = {
    Name = "ec2-db"
  }
}
# Create a VPC
resource "aws_vpc" "db_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "db_vpc"
    }

}

# Create a Subnet
resource "aws_subnet" "db_subnet"{
  vpc_id = aws_vpc.db_vpc.id
  cidr_block = "10.0.16.0/20"
  availability_zone  = "us-west-1b"   
  map_public_ip_on_launch = true

  tags = {
    Name = "db_Subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "db_geteway"{
  vpc_id = aws_vpc.db_vpc.id

  tags = {
    Name = "db_Geteway"
  }
}
# Create a Route
resource "aws_route_table" "db_route_table"{
  vpc_id = aws_vpc.db_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.db_geteway.id
  }

  tags = {
    Name = "db_route_table"
  }
}

# Create a Route associate
resource "aws_route_table_association" "db_route_table_association"{
  subnet_id = aws_subnet.db_subnet.id
  route_table_id = aws_route_table.db_route_table.id 
  
}

# Create a security group for the EC2 instance
resource "aws_security_group" "db_vpc_security_group"{
  name = "db_vpc_security_group"
  vpc_id = aws_vpc.db_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
}

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

    tags = {
      Name = "db_vpc_security_Group"
    }
}