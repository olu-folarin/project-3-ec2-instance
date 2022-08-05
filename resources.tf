# configure a data provider. the config right beneath this comment is unique to aws
resource "aws_default_vpc" "default_vpc" {

}

data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default_vpc.id]
  }
}

data "aws_ami" "latest_aws_linux_2_kernel" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# use the data provider below to get ami ids
data "aws_ami_ids" "latest_aws_linux_kernel_2_ids" {
  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

# create a security group
resource "aws_security_group" "http_server_secg" {
  name   = "http_server_secg"
  vpc_id = aws_default_vpc.default_vpc.id

  #   ingress specifies where traffic is allowed from
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #   where the http server can communicate with
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    name = "http_server_secg"
  }
}

# an ec2 instance
resource "aws_instance" "http_server" {
  ami = data.aws_ami.latest_aws_linux_2_kernel.id
  key_name               = "ec2-project1"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.http_server_secg.id]
  #   from line 6
  subnet_id = data.aws_subnets.vpc_subnets.ids[0]


  # adding an html file to the http server. use the keypair created here.
  connection {
    type = "ssh"
    #   the public ip can be found in tfstate
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.aws_key_pair)
  }

  provisioner "remote-exec" {
    inline = [
      # install httpd/http server
      "sudo yum install httpd -y",
      # start the server
      "sudo service httpd start",
      # copy a file
      "echo Here is a virtual server hosted on aws with an html file on it displaying this message for all to see. The virtual server is at ${self.public_dns}. | sudo tee /var/www/html/index.html"
    ]
  }
}