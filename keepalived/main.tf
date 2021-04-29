terraform {
  required_version = "~> 0.12.26"
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

data "aws_availability_zones" "available_azs" {
  state = "available"
}

######## VPC ########
resource "aws_vpc" "vpc_0" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    Name = "vpc_0"
  }
}

######## EIP ########
resource "aws_eip" "nat_eip" {
  vpc = true
}

######## Gateways ########
resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc_0.id
  tags = {
    Name = "internet_gw"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_0.id
  tags = {
    Name = "nat_gw"
  }
  depends_on = [aws_subnet.public_subnet_0]
}

######## Public Subnet ########
resource "aws_subnet" "public_subnet_0" {
  cidr_block              = "10.0.100.0/24"
  availability_zone       = data.aws_availability_zones.available_azs.names[0]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc_0.id
  tags = {
    Name = "public_subnet_0"
  }
  depends_on = [aws_vpc.vpc_0]
}

resource "aws_route_table" "public_route_0" {
  vpc_id = aws_vpc.vpc_0.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
  tags = {
    Name = "public_route_0"
  }
}

resource "aws_route_table_association" "assoc_table_main" {
  subnet_id      = aws_subnet.public_subnet_0.id
  route_table_id = aws_route_table.public_route_0.id
  depends_on     = [aws_subnet.public_subnet_0, aws_route_table.public_route_0]
}

######## Private Subnet ########
resource "aws_subnet" "private_subnet_0" {
  cidr_block              = "10.0.200.0/24"
  availability_zone       = data.aws_availability_zones.available_azs.names[0]
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.vpc_0.id
  tags = {
    Name = "private_subnet_0"
  }
  depends_on = [aws_vpc.vpc_0]
}

resource "aws_route_table" "private_route_0" {
  vpc_id = aws_vpc.vpc_0.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "private_route_0"
  }
  depends_on = [aws_nat_gateway.nat_gw]
}

resource "aws_route_table_association" "assoc_route_private" {
  subnet_id      = aws_subnet.private_subnet_0.id
  route_table_id = aws_route_table.private_route_0.id
  depends_on     = [aws_subnet.private_subnet_0, aws_route_table.private_route_0]
}

######## Security Groups ########
resource "aws_security_group" "haproxy_sg" {
  vpc_id = aws_vpc.vpc_0.id
  name   = "haproxy_sg"
  # outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # inbound rules
  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nginx_sg" {
  vpc_id = aws_vpc.vpc_0.id
  name   = "nginx_sg"
  # outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # inbound rules
  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.haproxy_sg.id]
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.haproxy_sg.id]
  }
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.haproxy_sg.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.haproxy_sg.id]
  }
}

######## AMI and EC2 ########
data "aws_ami" "ec2_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"] # Hardware-assisted virtualization
  }
  owners = ["amazon"]
}

data "template_file" "user_data_master" {
  template = file("${path.module}/user_data_master.sh")
  vars = {
    NGINX_IP   = "10.0.200.100"
    VIRTUAL_IP = "172.16.0.100"
  }
}

data "template_file" "user_data_slave" {
  template = file("${path.module}/user_data_slave.sh")
  vars = {
    NGINX_IP   = "10.0.200.100"
    VIRTUAL_IP = "172.16.0.100"
  }
}

data "template_file" "user_data_nginx" {
  template = file("${path.module}/user_data_nginx.sh")
  vars     = {}
}

resource "aws_network_interface" "eth0_master" {
  subnet_id       = aws_subnet.public_subnet_0.id
  private_ips     = ["10.0.100.100"]
  security_groups = [aws_security_group.haproxy_sg.id]
  tags = {
    Name = "eth0_master"
  }
  depends_on = [aws_subnet.public_subnet_0, aws_security_group.haproxy_sg]
}

resource "aws_network_interface" "eth0_slave" {
  subnet_id       = aws_subnet.public_subnet_0.id
  private_ips     = ["10.0.100.200"]
  security_groups = [aws_security_group.haproxy_sg.id]
  tags = {
    Name = "eth0_slave"
  }
  depends_on = [aws_subnet.public_subnet_0, aws_security_group.haproxy_sg]
}

# nginx will be placed on private subnet
resource "aws_network_interface" "eth0_nginx" {
  subnet_id       = aws_subnet.private_subnet_0.id
  private_ips     = ["10.0.200.100"]
  security_groups = [aws_security_group.nginx_sg.id]
  tags = {
    Name = "eth0_nginx"
  }
  depends_on = [aws_subnet.private_subnet_0, aws_security_group.haproxy_sg]
}

# keepalived master / haproxy
resource "aws_instance" "ec2_instance_master" {
  iam_instance_profile = "AmazonEC2Role"
  ami                  = data.aws_ami.ec2_ami.id
  instance_type        = var.aws_instance_size
  key_name             = var.aws_key_name
  user_data            = data.template_file.user_data_master.rendered
  network_interface {
    network_interface_id = aws_network_interface.eth0_master.id
    device_index         = 0
  }
  tags = {
    Name = "ec2_instance_master"
  }
  depends_on = [aws_network_interface.eth0_master]
}

output "ec2_instance_master" {
  value = aws_instance.ec2_instance_master.public_ip
}

# keepalived slave / haproxy
resource "aws_instance" "ec2_instance_slave" {
  iam_instance_profile = "AmazonEC2Role"
  ami                  = data.aws_ami.ec2_ami.id
  instance_type        = var.aws_instance_size
  key_name             = var.aws_key_name
  user_data            = data.template_file.user_data_slave.rendered
  network_interface {
    network_interface_id = aws_network_interface.eth0_slave.id
    device_index         = 0
  }
  tags = {
    Name = "ec2_instance_slave"
  }
  depends_on = [aws_network_interface.eth0_slave]
}

output "ec2_instance_slave" {
  value = aws_instance.ec2_instance_slave.public_ip
}

# nginx (not accessible from the internet)
resource "aws_instance" "ec2_instance_nginx" {
  iam_instance_profile = "AmazonEC2Role"
  ami                  = data.aws_ami.ec2_ami.id
  instance_type        = var.aws_instance_size
  key_name             = var.aws_key_name
  user_data            = data.template_file.user_data_nginx.rendered
  network_interface {
    network_interface_id = aws_network_interface.eth0_nginx.id
    device_index         = 0
  }
  tags = {
    Name = "ec2_instance_nginx"
  }
  depends_on = [aws_network_interface.eth0_nginx]
}

output "ec2_instance_nginx" {
  value = aws_instance.ec2_instance_nginx.public_ip
}
