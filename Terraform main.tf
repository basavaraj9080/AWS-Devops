provider "aws" {
  region = "ap-south-1"
  access_key = "AKIA47GB74PPFZ5US3XN"
  secret_key = "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"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Custom-VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id
    tags = {
      Name = "Custom-IGW"
    }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet"
  }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "public-rt-association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}
resource "aws_security_group" "ssh_sg" {
  name = "Allow SSH"
  description = "Allow SSH access"
  vpc_id = aws_vpc.my-vpc.id
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSH-Security-Group"
  }
}

resource "aws_instance" "ec2" {
  ami = "ami-02521d90e7410d9f0" # ubuntu
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ssh_sg.id]
  associate_public_ip_address = true
  key_name = "apr-1"

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  #user_data = file("server-script.sh") # Optional: comment/remove if not needed

  tags = {
    Name = "Jenkins-admin-server"
  }
}

# 8. Output Public IP
output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}
