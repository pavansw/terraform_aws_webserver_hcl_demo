terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.75.1"
    }
  }
}

provider "aws" {
access_key=var.myaccesskey
secret_key=var.mysecretkey
region=var.myregion
}

resource "aws_vpc" "myvpc" {
cidr_block=var.mycidr
instance_tenancy="default"
tags = {
    Name = "Pavan-main-vpc"
  }
}

## Creating Subnet to same vpc
resource "aws_subnet" "subnet1" {
vpc_id=aws_vpc.myvpc.id
cidr_block=var.mycidrsub1
availability_zone="ap-south-1b"
tags = {
    Name = "Pavan-main-vpc-subnet1"
  }
}

## creating Internet Gateway
resource "aws_internet_gateway" "mygw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "Pavan-main-IG"
  }
}

## Creating Route Table with Routes
resource "aws_route_table" "myroute1" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mygw.id
  }

  tags = {
    Name = "Pavan-MyRouteTable"
  }
}

### Lets create Route table association between route and subnet
resource "aws_route_table_association" "myroute1_assocaition" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.myroute1.id
}

#### Lets create Security Group for VPC
resource "aws_security_group" "mysg" {
  name        = "allow_ssh_http"
  description = "Allow 22 and 80 port inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "pavan_allow_ssh_http"
  }
}

## Ingress rule for ssh and http
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.mysg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  cidr_ipv4	    = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.mysg.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  cidr_ipv4       = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
/*
###   EC2 Instance or VM on the subnet 
resource "aws_instance" "myvm1" {
  ami= "ami-022ce6f32988af5fa"
  instance_type= "t2.micro"
  key_name= "pavan-terraform-hcl"
  subnet_id= aws_subnet.subnet1.id
  associate_public_ip_address= true
  vpc_security_group_ids= [aws_security_group.mysg.id]
  root_block_device {
    volume_type = "gp2"
   }
  tags= {
    Name= "PavanServer1"
   }
}
*/
resource "aws_instance" "myvm2" {
  ami= "ami-09b0a86a2c84101e1"
  instance_type= "t2.micro"
  key_name= "pavan-terraform-hcl"
  subnet_id= aws_subnet.subnet1.id
  associate_public_ip_address= true
  vpc_security_group_ids= [aws_security_group.mysg.id]
  root_block_device {
    volume_type = "gp2"
   }

user_data=<<-EOF
#!/bin/bash
sudo apt update
sudo apt install apache2 -y
echo "Hello From Pavan Wankhade" > /var/www/html/index.html
sudo systemctl start apache2
sudo systemctl enable apache2
EOF

  tags= {
    Name= "PavanServer1"
   }
}

