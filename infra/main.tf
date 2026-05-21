terraform {

  required_version = ">= 1.6"

  required_providers {

    aws = {

      source  = "hashicorp/aws"
      version = "~> 5.0"

    }

  }

}

provider "aws" {

  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key

}


resource "aws_vpc" "lake" {

  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {

    Name = "lake-vpc"

  }

}

resource "aws_internet_gateway" "lake" {

  vpc_id = aws_vpc.lake.id

}

resource "aws_subnet" "public" {

  vpc_id                  = aws_vpc.lake.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  availability_zone = "us-east-1a"

  tags = {

    Name = "lake-public"

  }

}

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.lake.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.lake.id

  }

}

resource "aws_route_table_association" "public" {

  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id

}


resource "aws_security_group" "lake" {

  name   = "lake-sg"
  vpc_id = aws_vpc.lake.id

  ingress {

    description = "SSH"

    from_port = 22
    to_port   = 22

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    description = "Port 8082"

    from_port = 8082
    to_port   = 8082

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    description = "Port 8085"

    from_port = 8085
    to_port   = 8085

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    description = "Port 8087"

    from_port = 8087
    to_port   = 8087

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    description = "MinIO Console"

    from_port = 9001
    to_port   = 9001

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {

    Name = "lake-sg"

  }

}


data "aws_ami" "ubuntu" {

  most_recent = true

  owners = ["099720109477"]

  filter {

    name = "name"

    values = [

      "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"

    ]

  }

}


resource "aws_instance" "lake" {

  ami = data.aws_ami.ubuntu.id

  instance_type = "t3.xlarge"

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [

    aws_security_group.lake.id

  ]

  associate_public_ip_address = true

  key_name  = "lake-key"
  user_data = file("${path.module}/userdata.sh")

  root_block_device {

    volume_size = 150

    volume_type = "gp3"

    delete_on_termination = true

  }

  tags = {

    Name = "lake-server"

  }

}

