resource "aws_codedeploy_app" "main" {
  compute_platform = "ECS"
  name             = "${var.prefix}-deploy"
}

resource "aws_codedeploy_deployment_group" "main" {
  app_name               = aws_codedeploy_app.main.name
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"
  deployment_group_name  = "${var.prefix}-deploy-group"
  service_role_arn       = aws_iam_role.codedeploy.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.main.name
    service_name = aws_ecs_service.main.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.blue.arn]
      }

      target_group {
        name = aws_lb_target_group.blue.name
      }

      target_group {
        name = aws_lb_target_group.green.name
      }

      test_traffic_route {
        listener_arns = [aws_lb_listener.green.arn]
      }
    }
  }

  # trigger_configuration {
  #     trigger_events = [
  #         "DeploymentSuccess",
  #         "DeploymentFailure"
  #     ]
  #     trigger_name = data.external.commit_message.result["message"]
  #     trigger_target_arn = var.sns_topic_arn  
  # }
  lifecycle {
    ignore_changes = [blue_green_deployment_config]
  }
}

resource "aws_codebuild_project" "main" {
  name          = "${var.prefix}-build"
  build_timeout = 60
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type         = "LINUX_CONTAINER"
    image        = "aws/codebuild/standard:2.0"
    compute_type = "BUILD_GENERAL1_SMALL"

    environment_variable {
      name  = "taskRoleArn"
      value = aws_iam_role.task_role.arn
    }
    environment_variable {
      name  = "exeRoleArn"
      value = aws_iam_role.ecs_task_execution_role.arn
    }
    environment_variable {
      name  = "cName"
      value = local.task-def.containerDefinitions[0].name
    }
    environment_variable {
      name  = "region"
      value = split(".", local.task-def.containerDefinitions[0].image)[3]
    }
    environment_variable {
      name  = "family"
      value = local.task-def.family
    }
    environment_variable {
      name  = "apmServer"
      value = var.apm-server-ip
    }
    environment_variable {
      name  = "dbDomain"
      value = var.db-domain
    }
    environment_variable {
      name  = "dbUser"
      value = var.db-user
    }
    environment_variable {
      name  = "dbPw"
      value = var.db-pw
    }
    environment_variable {
      name  = "bucketName"
      value = aws_s3_bucket.pipeline_bucket.bucket
    }
  }
  source {
    type      = "NO_SOURCE"
    buildspec = file("${path.module}/BuildSpec.yml")
  }
}
