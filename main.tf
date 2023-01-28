provider "aws" {
	access_key = "======================"
	secret_key = "======================"
	region = "ap-south-1"
}

resource "aws_vpc" "dev_vpc" {
	cidr_block = "10.1.0.0/16"
	tags = {
		Name = "dev_vpc"
	}
}

resource "aws_internet_gateway" "dev_IGW" {
	vpc_id = aws_vpc.dev_vpc.id
	tags = {
		Name = "dev_IGW"
	}
}

resource "aws_subnet" "dev_subnet" {
	vpc_id = aws_vpc.dev_vpc.id
	cidr_block = "10.1.1.0/24"
	availability_zone = "ap-south-1a"
	map_public_ip_on_launch = "true"
	tags = {
		Name = "dev_subnet"
	}
}

resource "aws_route_table" "dev_rtb" {
	vpc_id = aws_vpc.dev_vpc.id
	tags = {
		Name = "dev_rtb"
	}
}

resource "aws_route" "dev_route" {
        route_table_id = aws_route_table.dev_rtb.id
        destination_cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.dev_IGW.id
}

resource "aws_route_table_association" "dev_route_assoc" {
	route_table_id = aws_route_table.dev_rtb.id
	subnet_id = aws_subnet.dev_subnet.id
}
resource "aws_security_group" "my_vpc_sg" {

	name = "my_vpc_sg"
	vpc_id = aws_vpc.dev_vpc.id
	ingress {
		from_port = "22"
		to_port = "22"
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		}
	ingress {
		from_port = "0"
		to_port = "0"
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		}
	egress {
		from_port = "0"
		to_port = "0"
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		}
	tags = {
		Name = "my_vpc_sg"
		}
}

resource "aws_instance" "my-vpc-ubuntu" {
	ami = "ami-0f69bc5520884278e"
	instance_type = "t2.micro"
	subnet_id = aws_subnet.dev_subnet.id
	vpc_security_group_ids = [aws_security_group.my_vpc_sg.id]
	user_data = "${file("mydata.sh")}"
	key_name = "KeyPairJan2022"	
	tags = {
		Name = "my-vpc-ubuntu"
	}
}


output "myinstance_ip" {value = aws_instance.my-vpc-ubuntu.public_ip}
