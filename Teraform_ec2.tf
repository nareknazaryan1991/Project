# Region
provider "aws" {
  region = "us-east-1" 
}

resource "aws_instance" "ec2-db" {
  ami                         = data.aws_ami.ec2-db.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.ec2_key.key_name
  tags = {
    Name = "ec2-db"
  }

}

# Create a VPC
resource "aws_vpc" "terraform_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Terraform_vpc"
    }

}

# Create a Subnet
resource "aws_subnet" "terraform_subnet"{
  vpc_id = aws_vpc.terraform_vpc.id
  cidr_block = "10.0.16.0/20"
  availability_zone  = "us-east-1a"   
  map_public_ip_on_launch = true

  tags = {
    Name = "Terraform_Subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "terraform_geteway"{
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "Terraform_Geteway"
  }
}
# Create a Route
resource "aws_route_table" "terraform_route_table"{
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_geteway.id
  }

  tags = {
    Name = "Terraform_route_table"
  }
}

# Create a Route associate
resource "aws_route_table_association" "terraform_route_table_association"{
  subnet_id = aws_subnet.terraform_subnet.id
  route_table_id = aws_route_table.terraform_route_table.id 
  
}

# Create a security group for the EC2 instance
resource "aws_security_group" "terraform_vpc_security_group"{
  name = "terraform_vpc_security_group"
  vpc_id = aws_vpc.terraform_vpc.id

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
      Name = "Terraform_vpc_security_Group"
    }
}