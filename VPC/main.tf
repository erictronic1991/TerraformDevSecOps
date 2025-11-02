provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_vpc" "development_vpc" {
  cidr_block           = "10.0.0.0/16"
}
resource "aws_subnet" "dev_public_subnet" {
  vpc_id     = aws_vpc.development_vpc.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "ap-southeast-1a"
}
resource "aws_subnet" "dev_private_subnet" {
  vpc_id     = aws_vpc.development_vpc.id
  cidr_block = "10.0.20.0/24"
  availability_zone = "ap-southeast-1a"
}
resource "aws_route_table" "dev_public_rt" {
  vpc_id = aws_vpc.development_vpc.id
}
resource "aws_instance" "web_server" {
  ami           = "ami-0609186b60570e9c9" # Amazon Linux 2 AMI (HVM), SSD Volume Type in ap-southeast-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.dev_public_subnet.id

  tags = {
    Name = "DevelopmentWebServer"
  }
}


