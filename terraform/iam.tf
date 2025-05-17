resource "aws_iam_role" "ecs_task_execution_role" {
name               = "ecs_task_execution_role"
assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
tags = {
        Name = "ecs_task_execution_role"
    }
}


data "aws_iam_policy_document" "ecs_assume_role_policy" {
    statement {
        actions = ["sts:AssumeRole"]
        principals {
            type        = "Service"
            identifiers = ["ecs-tasks.amazonaws.com"]
        }
    }
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_cloudwatch_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}


resource "aws_iam_role_policy" "ecs_task_secrets_access_policy" {
  name   = "ecs-task-secrets-access"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = data.aws_iam_policy_document.ecs_task_secrets_access_policy.json
}

data "aws_iam_policy_document" "ecs_task_secrets_access_policy" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      "arn:aws:secretsmanager:us-east-1:703671921064:secret:github-container-registry-auth*"
    ]
  }
}

