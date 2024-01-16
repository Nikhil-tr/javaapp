#VPC
resource "aws_vpc" "dev"{
 tags = {
   Name = "dev-vpc"
 }
 cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "dev-public1" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "dev-public-1-ap-south-1a"
  }
}

resource "aws_subnet" "dev-public2" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "dev-public-2-ap-south-1b"
  }
}


resource "aws_subnet" "dev-private1" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "dev-private-1-ap-south-1a"
  }
}
resource "aws_subnet" "dev-private2" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "dev-private-2-ap-south-1b"
  }
}

resource "aws_route_table" "dev-public-rt" {
 vpc_id = aws_vpc.dev.id
 tags = {
   Name = "dev-public-rt"
 }
}

resource "aws_route_table" "dev-private-rt" {
 vpc_id = aws_vpc.dev.id
 tags = {
   Name = "dev-private-rt"
 }
}

resource "aws_internet_gateway" "dev-igw"{
 tags = {
   Name = "dev-igw"
 }
 vpc_id = aws_vpc.dev.id
}

resource "aws_eip" "dev-eip" {
  domain = "vpc"
}
resource "aws_nat_gateway" "dev-ngw" {
 tags = {
   Name = "dev-ngw"
 }
 subnet_id = aws_subnet.dev-public1.id
 allocation_id = aws_eip.dev-eip.id
}


resource "aws_route" "route-to-dev-igw"{
 route_table_id = aws_route_table.dev-public-rt.id
 destination_cidr_block = "0.0.0.0/0"
 gateway_id = aws_internet_gateway.dev-igw.id
}

resource "aws_route" "route-to-dev-ngw"{
 route_table_id = aws_route_table.dev-private-rt.id
 destination_cidr_block = "0.0.0.0/0"
 gateway_id = aws_nat_gateway.dev-ngw.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.dev-public1.id
  route_table_id = aws_route_table.dev-public-rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.dev-public2.id
  route_table_id = aws_route_table.dev-public-rt.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.dev-private1.id
  route_table_id = aws_route_table.dev-private-rt.id
}

resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.dev-private2.id
  route_table_id = aws_route_table.dev-private-rt.id
}

#KEY_GENERATE


#CREATE_SG
resource "aws_security_group" "dev-sg-priv" {
  name        = "dev-sg-priv"
  description = "Allow ssh inbound and all-outbound traffic"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
   description      = "allow all traffic"
   from_port        = 0
   to_port          = 0
   protocol         = "-1"
   cidr_blocks      = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "dev-sg-pub" {
  name        = "dev-sg-pub"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.dev.id

  ingress {
   description      = "allow-all-traffic"
   from_port        = 0
   to_port          = 0
   protocol         = "-1"
   cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
   description      = "allow all traffic"
   from_port        = 0
   to_port          = 0
   protocol         = "-1"
   cidr_blocks      = ["0.0.0.0/0"]
  }
}

#DEPLOY_INSTANCES
resource "aws_instance" "dev-inst-1"{
 tags = {
   Name = "dev-1"
 }
 ami = "ami-03f4878755434977f"
 instance_type = "t2.micro"
 key_name = "dev-proj-key"
 subnet_id = aws_subnet.dev-private1.id
 associate_public_ip_address = false
 security_groups = [aws_security_group.dev-sg-priv.id]
 user_data = <<-EOF
                     #!/bin/bash
                     sudo su -
                     hostnamectl set-hostname dev1
                 EOF
}
resource "aws_instance" "dev-inst-2"{
 tags = {
   Name = "dev-2"
 }
 ami = "ami-03f4878755434977f"
 instance_type = "t2.micro"
 key_name = "dev-proj-key"
 subnet_id = aws_subnet.dev-private2.id
 associate_public_ip_address = false
 security_groups = [aws_security_group.dev-sg-priv.id]
 user_data = <<-EOF
                     #!/bin/bash
                     sudo su -
                     hostnamectl set-hostname dev2
                 EOF
}
resource "aws_instance" "dev-pub-inst-1"{
 tags = {
   Name = "master-inst"
 }
 ami = "ami-03f4878755434977f"
 instance_type = "t2.medium"
 key_name = "dev-proj-key"
 subnet_id = aws_subnet.dev-public1.id
 associate_public_ip_address = true
 security_groups = [aws_security_group.dev-sg-pub.id]
 user_data = <<-EOF
                     #!/bin/bash
                     sudo su -
                     hostnamectl set-hostname test
                     wget https://raw.githubusercontent.com/Nikhil-tr/install/main/ansible.sh
                     /bin/bash ansible.sh
                     mkdir ansible
                     cd ansible
                     wget https://raw.githubusercontent.com/Nikhil-tr/proj3/main/jenkins/install.sh
                     wget https://raw.githubusercontent.com/Nikhil-tr/proj3/main/jenkins/play.yaml
                     ansible-playbook play.yaml
                 EOF
}
