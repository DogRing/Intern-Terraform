resource "aws_appautoscaling_target" "main" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "to-cpu" {
  name               = "${var.prefix}-as-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.main.resource_id
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension
  service_namespace  = aws_appautoscaling_target.main.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 40
    scale_in_cooldown  = 10
    scale_out_cooldown = 10
  }
}

# resource "aws_appautoscaling_policy" "alb-traffic" {
#   name               = "${var.prefix}-as-cpu"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.main.resource_id
#   scalable_dimension = aws_appautoscaling_target.main.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.main.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ALBRequestCountPerTarget"
#       resource_label         = "${aws_lb.main.arn_suffix}/${aws_lb_target_group.blue.arn_suffix}"
#     }
#     target_value       = 100
#     scale_in_cooldown  = 10
#     scale_out_cooldown = 10
#   }
# }

# resource "aws_appautoscaling_policy" "to-mem" {
#   name               = "${var.prefix}-as-mem"
#   policy_type        = "TargetTrackingScaling"
#   resource_id        = aws_appautoscaling_target.main.resource_id
#   scalable_dimension = aws_appautoscaling_target.main.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.main.service_namespace

#   target_tracking_scaling_policy_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ECSServiceAverageMemoryUtilization"
#     }
#     target_value       = 
#     scale_in_cooldown  = 10
#     scale_out_cooldown = 10
#   }
# }
