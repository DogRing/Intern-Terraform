resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"
}

resource "aws_ecs_service" "main" {
  name                 = "${var.prefix}-service"
  cluster              = aws_ecs_cluster.main.id
  task_definition      = aws_ecs_task_definition.main.arn
  desired_count        = var.min_capacity
  launch_type          = "FARGATE"
  force_new_deployment = true

  network_configuration {
    security_groups = [aws_security_group.task.id]
    subnets         = var.private_subnets_id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.id
    container_name   = "spring"
    container_port   = var.target-port
  }
  depends_on = [aws_lb_listener.blue]
  lifecycle {
    ignore_changes = [
      desired_count,
      load_balancer,
      task_definition
    ]
  }
  deployment_controller {
    type = "CODE_DEPLOY"
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = local.task-def.family
  network_mode             = local.task-def.networkMode
  requires_compatibilities = local.task-def.requiresCompatibilities
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = local.task-def.cpu
  memory                   = local.task-def.memory
  task_role_arn            = aws_iam_role.task_role.arn
  container_definitions    = jsonencode(local.task-def.containerDefinitions)
}

locals {
  task-def = jsondecode(data.template_file.task-definition.rendered)
}

data "template_file" "task-definition" {
  template = file("./${var.task-def}")

  vars = {
    apm-server  = var.apm-server-ip
    db-domain   = var.db-domain
    db-user     = "testuser"
    db-pw       = "test1234"
    bucket-name = aws_s3_bucket.pipeline_bucket.bucket
  }
}

resource "aws_s3_object" "app-spec" {
  bucket = aws_s3_bucket.pipeline_bucket.bucket
  source = "./${var.task-def}"
  key    = "scripts/taskdef.json"
}

resource "aws_s3_object" "task-definition" {
  bucket = aws_s3_bucket.pipeline_bucket.bucket
  source = "${path.module}/AppSpec.yaml"
  key    = "scripts/appspec.yaml"
}

resource "aws_route53_record" "main" {
  zone_id = var.route53_zone_id
  name    = "${var.domain_name}.${var.route53_zone_name}"
  type    = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = false
  }
}
