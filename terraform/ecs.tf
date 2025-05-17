resource "aws_security_group" "ecs_sg" {
  name        = "ecs_security_group"
  description = "Security group that allows network traffic from alb to ecs"
  vpc_id      = aws_vpc.vpc_app.id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name = "ecs_security_group"
    }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"
}

resource "aws_cloudwatch_log_group" "nodejs_app" {
  name              = "/ecs/nodejs-app"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "nodejs_app_task" {
  family                   = "ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = "256"
  memory                  = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "nodejs_app"
      image = "ghcr.io/${var.github_repo}:latest"
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      repositoryCredentials = {
        credentialsParameter = "arn:aws:secretsmanager:us-east-1:703671921064:secret:github-container-registry-auth"
      }
      logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/nodejs-app"
        awslogs-region        = var.region
        awslogs-stream-prefix = "ecs"
      }
      }
    }
  ])
   depends_on = [aws_cloudwatch_log_group.nodejs_app]

}


resource "aws_ecs_service" "nodejs_app_service" {
  name            = "nodejs-app-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.nodejs_app_task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = aws_subnet.private_subnet[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }
    load_balancer {
        target_group_arn = aws_lb_target_group.nodejs_app_tg.arn
        container_name   = "nodejs_app"
        container_port   = var.container_port
    }
    depends_on = [aws_alb_listener.nodejs_app_listener]
    tags = {
        Name = "nodejs-app-service"
    }
}
