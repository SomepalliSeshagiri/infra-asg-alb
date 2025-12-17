# Amazon Linux 2 AMI (example for us-east-1; update if needed)
locals {
  ami_id = "ami-0c02fb55956c7d316"
}

# Simple user data: install httpd and serve a page
locals {
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    echo "<h1>ASG Demo: $(hostname)</h1>" > /var/www/html/index.html
    systemctl enable httpd
    systemctl start httpd
  EOF
}

resource "aws_launch_template" "lt" {
  name_prefix   = "demo-lt-"
  image_id      = local.ami_id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "demo-asg-instance" }
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "demo-asg"
  min_size            = 1
  desired_capacity    = 2
  max_size            = 4

  vpc_zone_identifier = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "demo-asg-instance"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb_listener.http]
}



