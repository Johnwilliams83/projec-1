#creating security_group for ecs
resource "aws_security_group" "my-ecs-sg" {
  name        = "my-ecs-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.pro-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.pro-vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "my-ecs-sg"
  }
}