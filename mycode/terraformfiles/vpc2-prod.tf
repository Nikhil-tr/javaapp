#VPC
resource "aws_vpc" "prod"{
 tags = {
   Name = "prod-vpc"
 }
 cidr_block = "20.0.0.0/16"
}

resource "aws_subnet" "prod-public1" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "20.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "prod-public1-ap-south-1a"
  }
}

resource "aws_subnet" "prod-public2" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "20.0.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "prod-public-2-ap-south-1b"
  }
}

resource "aws_subnet" "prod-public3" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "20.0.3.0/24"
  availability_zone = "ap-south-1c"
  tags = {
    Name = "prod-public-3-ap-south-1c"
  }
}


resource "aws_subnet" "prod-private1" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "20.0.4.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "prod-private-1-ap-south-1a"
  }
}
resource "aws_subnet" "prod-private2" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "20.0.5.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "prod-private-2-ap-south-1b"
  }
}
resource "aws_subnet" "prod-private3" {
  vpc_id     = aws_vpc.prod.id
  cidr_block = "20.0.6.0/24"
  availability_zone = "ap-south-1c"
  tags = {
    Name = "prod-private-3-ap-south-1c"
  }
}


resource "aws_route_table" "prod-public-rt" {
 vpc_id = aws_vpc.prod.id
 tags = {
   Name = "prod-public-rt"
 }
}

resource "aws_route_table" "prod-private-rt" {
 vpc_id = aws_vpc.prod.id
 tags = {
   Name = "prod-private-rt"
 }
}

resource "aws_internet_gateway" "prod-igw"{
 tags = {
   Name = "prod-igw"
 }
 vpc_id = aws_vpc.prod.id
}

resource "aws_eip" "prod-eip" {
  domain = "vpc"
}
resource "aws_nat_gateway" "prod-ngw" {
 tags = {
   Name = "prod-ngw"
 }
 subnet_id = aws_subnet.prod-public1.id
 allocation_id = aws_eip.prod-eip.id
}

resource "aws_route" "route-to-prod-igw"{
 route_table_id = aws_route_table.prod-public-rt.id
 destination_cidr_block = "0.0.0.0/0"
 gateway_id = aws_internet_gateway.prod-igw.id
}

resource "aws_route" "route-to-prod-ngw"{
 route_table_id = aws_route_table.prod-private-rt.id
 destination_cidr_block = "0.0.0.0/0"
 gateway_id = aws_nat_gateway.prod-ngw.id
}

resource "aws_route_table_association" "e" {
  subnet_id      = aws_subnet.prod-public1.id
  route_table_id = aws_route_table.prod-public-rt.id
}

resource "aws_route_table_association" "f" {
  subnet_id      = aws_subnet.prod-public2.id
  route_table_id = aws_route_table.prod-public-rt.id
}
resource "aws_route_table_association" "g" {
  subnet_id      = aws_subnet.prod-public3.id
  route_table_id = aws_route_table.prod-public-rt.id
}

resource "aws_route_table_association" "h" {
  subnet_id      = aws_subnet.prod-private1.id
  route_table_id = aws_route_table.prod-private-rt.id
}

resource "aws_route_table_association" "i" {
  subnet_id      = aws_subnet.prod-private2.id
  route_table_id = aws_route_table.prod-private-rt.id
}
resource "aws_route_table_association" "j" {
  subnet_id      = aws_subnet.prod-private3.id
  route_table_id = aws_route_table.prod-private-rt.id
}

#KEY_GENERATE


#CREATE_SG
resource "aws_security_group" "prod-sg-priv" {
  name        = "prod-sg-priv"
  description = "Allow ssh inbound and all-outbound traffic"
  vpc_id      = aws_vpc.prod.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "for kube join"
    from_port        = 6443
    to_port          = 6443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
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
resource "aws_security_group" "prod-sg-pub" {
  name        = "prod-sg-pub"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.prod.id

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
resource "aws_instance" "prod-inst-1"{
 tags = {
   Name = "inst-1"
 }
 ami = "ami-03f4878755434977f"
 instance_type = "t2.medium"
 key_name = "prod-proj-key"
 subnet_id = aws_subnet.prod-private1.id
 associate_public_ip_address = false
 security_groups = [aws_security_group.prod-sg-priv.id]
 user_data = <<-EOF
                     #!/bin/bash
                     sudo su -
                     hostnamectl set-hostname inst1
                     sudo apt-get update -y
                     wget https://raw.githubusercontent.com/Nikhil-tr/install/main/kube-master.sh
                     /bin/bash kube-master.sh -y
                 EOF
}
resource "aws_instance" "prod-inst-2"{
 tags = {
   Name = "inst-2"
 }
 ami = "ami-03f4878755434977f"
 instance_type = "t2.medium"
 key_name = "prod-proj-key"
 subnet_id = aws_subnet.prod-private2.id
 associate_public_ip_address = false
 security_groups = [aws_security_group.prod-sg-priv.id]
 user_data = <<-EOF
                     #!/bin/bash
                     sudo su -
                     hostnamectl set-hostname inst2
                     sudo apt-get update -y
                     wget https://raw.githubusercontent.com/Nikhil-tr/install/main/kube-client.sh
                     /bin/bash kube-client.sh -y
                 EOF
}
resource "aws_instance" "prod-inst-3"{
 tags = {
   Name = "inst-3"
 }
 ami = "ami-03f4878755434977f"
 instance_type = "t2.medium"
 key_name = "prod-proj-key"
 subnet_id = aws_subnet.prod-private2.id
 associate_public_ip_address = false
 security_groups = [aws_security_group.prod-sg-priv.id]
 user_data = <<-EOF
                     #!/bin/bash
                     sudo su -
                     hostnamectl set-hostname inst3
                     sudo apt-get update -y
                     wget https://raw.githubusercontent.com/Nikhil-tr/install/main/kube-client.sh
                     /bin/bash kube-client.sh -y
                 EOF
}
resource "aws_instance" "prod-inst-4"{
 tags = {
   Name = "bastion-host"
 }
 ami = "ami-03f4878755434977f"
 instance_type = "t2.medium"
 key_name = "prod-proj-key"
 subnet_id = aws_subnet.prod-public1.id
 associate_public_ip_address = true
 security_groups = [aws_security_group.prod-sg-pub.id]
 user_data = <<-EOF
                     #!/bin/bash
                     sudo su -
                     hostnamectl set-hostname bastion
                     wget https://raw.githubusercontent.com/Nikhil-tr/install/main/kube-client.sh
                     /bin/bash kube-client.sh -y
                 EOF
}

#TARGET_GROUP_CREATION
resource "aws_lb_target_group" "prod-tg" {
  name     = "prod-tg"
  protocol = "HTTP"
  port     = 80
  vpc_id   = aws_vpc.prod.id
}
#ATTACH_INSTANCES_TO_TG
resource "aws_lb_target_group_attachment" "prod-tg-attach1" {
  target_group_arn = aws_lb_target_group.prod-tg.arn
  target_id        = aws_instance.prod-inst-1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "prod-tg-attach2" {
  target_group_arn = aws_lb_target_group.prod-tg.arn
  target_id        = aws_instance.prod-inst-2.id
  port             = 80
}

#CREATE_APPLICATION_LOADBALANCER
resource "aws_lb" "prod-lb" {
  load_balancer_type = "application"
  name               = "prod-lb"
  internal           = false
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.prod-sg-pub.id]
  subnets            = [
  aws_subnet.prod-public1.id,
  aws_subnet.prod-public2.id,
  aws_subnet.prod-public3.id
  ]
  enable_deletion_protection = false
}

resource "aws_lb_listener" "prod-lb-listener" {
  load_balancer_arn = aws_lb.prod-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod-tg.arn
  }
}

output "dns_name" {
 value =  aws_lb.prod-lb.dns_name
}
