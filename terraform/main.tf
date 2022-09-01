variable "awsprops" {
    type = map
    default = {
    region = "us-east-1"
    ami = "ami-090fa75af13c156b4"
    itype = "t2.micro"
    subnet = "subnet-81896c8e"
    publicip = true
    keyname = "myseckeys"
    secgroupname = "IAC-Sec-Group"
  }
}

provider "aws" {
  region = lookup(var.awsprops, "region")
}

resource "aws_vpc" "vpc_main" {
  cidr_block       = "191.0.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "public_vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc_main.id}"
  cidr_block = "191.0.0.0/24"
  tags = {
    Name        ="public-subnet"
  }
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = "${aws_vpc.vpc_main.id}"

  tags = {
    Name = "main"
  }
}


resource "aws_route_table" "vpc_route_tab" {
  vpc_id = "${aws_vpc.vpc_main.id}"

  route {
    cidr_block        = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gw.id}"
  }
  
  tags = {
    Name = "example"
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = "${aws_vpc.vpc_main.id}"
  route_table_id = "${aws_route_table.vpc_route_tab.id}"
}

resource "aws_security_group" "project-iac-sg" {
  name = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id = "${aws_vpc.vpc_main.id}"

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  // To Allow Port 8080 Transport
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "jenkins_server" {
  ami           = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = "${aws_subnet.public_subnet.id}"
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = lookup(var.awsprops, "keyname")


  vpc_security_group_ids = [
    aws_security_group.project-iac-sg.id
  ]
  
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update –y
	sudo wget -O /etc/yum.repos.d/jenkins.repo \
	  https://pkg.jenkins.io/redhat-stable/jenkins.repo
	sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
	sudo yum upgrade -y
	sudo amazon-linux-extras install java-openjdk11 -y
	sudo yum install jenkins -y
	sudo systemctl enable jenkins
	sudo systemctl start jenkins
	sudo yum install git -y
	sudo yum install maven -y
	sudo yum install docker -y
  EOF
  
  tags = {
    Name = "jenkins_server"
  }
}

resource "aws_instance" "app1_server" {
  ami           = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = "${aws_subnet.public_subnet.id}"
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = lookup(var.awsprops, "keyname")


  vpc_security_group_ids = [
    aws_security_group.project-iac-sg.id
  ]
  
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update –y
	sudo yum tomcat -y
	sudo yum install docker -y
  EOF
  
  tags = {
    Name = "app1_server"
  }
}

resource "aws_instance" "app2_server" {
  ami           = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = "${aws_subnet.public_subnet.id}"
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = lookup(var.awsprops, "keyname")


  vpc_security_group_ids = [
    aws_security_group.project-iac-sg.id
  ]
  
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update –y
	sudo yum tomcat -y
	sudo yum install docker -y
  EOF
  
  tags = {
    Name = "app2_server"
  }
}




output "ec2instance" {
  value = aws_instance.jenkins_server.public_ip
}
