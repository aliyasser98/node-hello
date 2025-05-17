resource "aws_lb" "nodejs_app_alb" {
name               = "nodejs-app-alb"
internal           = false
load_balancer_type = "application"
security_groups    = [aws_security_group.alb_sg.id]
subnets            = aws_subnet.public_subnet[*].id
enable_deletion_protection = false
enable_cross_zone_load_balancing = true
idle_timeout       = 60
tags = {
        Name = "nodejs-app-alb"
    }
}


resource "aws_lb_target_group" "nodejs_app_tg" {
  name     = "nodejs-app-tg"
  port     = 3000
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.vpc_app.id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
  tags = {
        Name = "nodejs-app-tg"
    }
}


resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.vpc_app.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
            Name = "alb_sg"
    }
}


resource "aws_alb_listener" "nodejs_app_listener" {
    load_balancer_arn = aws_lb.nodejs_app_alb.arn
    port              = 80
    protocol          = "HTTP"
    
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.nodejs_app_tg.arn
    }
    tags = {
            Name = "nodejs-app-listener"
        }
}