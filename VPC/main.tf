provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_vpc" "development_vpc" {
  cidr_block           = "10.0.0.0/16"
  tags = {
    Name = "DevelopmentVPC"
  }
}
resource "aws_subnet" "dev_public_subnet" {
  vpc_id     = aws_vpc.development_vpc.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "DevelopmentPublicSubnet"
  }
}
resource "aws_subnet" "dev_private_subnet" {
  vpc_id     = aws_vpc.development_vpc.id
  cidr_block = "10.0.20.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "DevelopmentPrivateSubnet"
  }
}
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.development_vpc.id

  tags = {
    Name = "DevelopmentIGW"
  }
}

resource "aws_route_table" "dev_public_rt" {
  vpc_id = aws_vpc.development_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }

  tags = {
    Name = "DevelopmentPublicRT"
  }
}

resource "aws_route_table_association" "dev_public_rta" {
  subnet_id      = aws_subnet.dev_public_subnet.id
  route_table_id = aws_route_table.dev_public_rt.id
}
resource "aws_instance" "web_server1" {
  ami           = "ami-0609186b60570e9c9" # Amazon Linux 2 AMI (HVM), SSD Volume Type in ap-southeast-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.dev_public_subnet.id
  vpc_security_group_ids = [aws_security_group.EC2instance_SG.id    ]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Welcome to Development Web Server 1</h1>" > /var/www/html/index.html
              EOF

  user_data_replace_on_change = true
  
  tags = {
    Name = "DevelopmentWebServer1"
  }
}

resource "aws_security_group" "EC2instance_SG" {
  name        = "EC2Instance_SG"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.development_vpc.id

  ingress {
    from_port   = 80    # HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
        from_port   = 22    # SSH
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
}