resource "aws_cloudwatch_event_rule" "main" {
  name          = "${var.prefix}-ecr-trigger"
  description   = "Capture ECR push event"
  event_pattern = <<EOF
{
    "source": ["aws.ecr"],
    "detail-type": ["ECR Image Action"],
    "detail": {
        "action-type": ["PUSH"],
        "result": ["SUCCESS"],
        "repository-name": ["${split(":", split("/", local.task-def.containerDefinitions[0].image)[1])[0]}"],
        "image-tag": ["${aws_codepipeline.main.stage[0].action[0].configuration.ImageTag}"]
    }
}
EOF
}

resource "aws_cloudwatch_event_target" "main" {
  rule      = aws_cloudwatch_event_rule.main.name
  target_id = "${var.prefix}-trigger-pipeline"
  arn       = aws_codepipeline.main.arn
  role_arn  = aws_iam_role.trigger-role.arn
}
