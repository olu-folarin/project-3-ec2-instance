# create a security group
resource "aws_security_group" "http_server_secg" {
  name   = "http_server_secg"
  vpc_id = "vpc-075343a660b9eb15c"

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
}