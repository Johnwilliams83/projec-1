#creating ecs_cluster for project
resource "aws_ecs_cluster" "my-pro-ecs" {
  name = "my-pro-ecs"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


#creating ecs_service for a project
resource "aws_ecs_service" "my-ecs-service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.my-pro-ecs.id
  task_definition = aws_ecs_task_definition.my-ecs_task_def.arn
  desired_count   = 1
  iam_role        = aws_iam_role.my-iam_role.arn

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
}

# Network_load_balancer for ecs projects

resource "aws_lb" "ecs_nlb" {
  name                       = "test-lb-tf"
  internal                   = false
  load_balancer_type         = "network"
  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}


#Aws_lb_listerner

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.ecs_nlb.id

  default_action {
    target_group_arn = aws_lb_target_group.my-lb-tg.id
    type             = "forward"
  }
}


#  Target Group
resource "aws_lb_target_group" "my-lb-tg" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.pro-vpc.id
}



#Iam_role_policy
resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

#aws_iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.my-iam_role.name
  policy_arn = aws_iam_policy.policy.arn
}


# Iam_role for ecs
resource "aws_iam_role" "my-iam_role" {
  name = "my-iam_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

# Task_definition for ecs
resource "aws_ecs_task_definition" "my-ecs_task_def" {
  family = "my-ecs_task_def"
  container_definitions = jsonencode([
    {
      name      = "first"
      image     = "service-first"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },
    {
      name      = "second"
      image     = "service-second"
      cpu       = 10
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 443
          hostPort      = 443
        }
      ]
    }
  ])

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [eu-west-1]"
  }
}
