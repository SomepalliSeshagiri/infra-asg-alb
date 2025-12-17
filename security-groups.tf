# ALB security group: allow inbound HTTP from the world
resource "aws_security_group" "alb_sg" {
  name = "demo-alb-sg"
  description = "Allow HTTP to ALB"
  vpc_id = aws_vpc.demo.id
  
  ingress {
    description = "HTTP from anywhere"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = { Name = "demo-alb-sg" }
}

# App instances: allow port 80 from the ALB only
resource "aws_security_group" "app_sg" {
  name        = "demo-app-sg"
  description = "Allow HTTP from ALB"
  vpc_id      = aws_vpc.demo.id

  ingress {
    description              = "HTTP from ALB"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    security_groups          = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "demo-app-sg" }
}


