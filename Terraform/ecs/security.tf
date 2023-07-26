resource "aws_security_group" "lb" {
  name   = "${var.prefix}-alb-sg"
  vpc_id = var.vpc_id
  tags   = { Name = "${var.prefix}-alb" }
}

resource "aws_security_group_rule" "lb-ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.lb.id
  count             = length(var.lb-in-port)
  from_port         = var.lb-in-port[count.index]
  to_port           = var.lb-in-port[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb-egress" {
  type              = "egress"
  security_group_id = aws_security_group.lb.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.prefix}-task-exe-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "ecs-tasks.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
    }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_exection_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task_role" {
  name               = "${var.prefix}-task-role"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
          "Service": [
            "ec2.amazonaws.com",
            "ecs-tasks.amazonaws.com"
          ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "task_log" {
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "task_ec2" {
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "task_access_s3" {
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role" "codedeploy" {
  name               = "${var.prefix}-codedeploy-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "codedeploy.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
    }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

resource "aws_iam_role" "codebuild" {
  name               = "${var.prefix}-codebuild-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": [
                "codebuild.amazonaws.com"
            ]
        },
        "Effect": "Allow",
        "Sid": ""
    }]
}
EOF
}

resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.name

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
            "Sid": "CloudWatchLog",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecs:ListTaskDefinitions"
            ],
            "Sid": "ForRevision",
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

resource "aws_iam_role_policy_attachment" "codebuild_s3" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role" "codepipeline" {
  name               = "${var.prefix}-codepipeline-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": [
                "codepipeline.amazonaws.com",
                "codebuild.amazonaws.com",
                "codedeploy.amazonaws.com"
            ]
        },
        "Effect": "Allow",
        "Sid": ""
    }]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline" {
  role = aws_iam_role.codepipeline.name

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:DescribeImages"

            ],
            "Sid": "ECRAccessPrincipal",
            "Resource": "*"
        },{
            "Sid": "CodeBuildPrincipal",
            "Effect": "Allow",
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Resource": "*"
        },{
            "Sid": "CodeDeployPrincipal",
            "Effect": "Allow",
            "Action": [
                "codedeploy:GetApplication",
                "codedeploy:GetApplicationRevision",
                "codedeploy:CreateDeployment",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision",
                "ecs:RegisterTaskDefinition",
                "iam:*"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_role" "trigger-role" {
  name               = "${var.prefix}-trigger"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "events.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "trigger-policy" {
  description = "chwan codepipeline trigger exe"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "codepipeline:StartPipelineExecution",
            "Effect": "Allow",
            "Resource": "${aws_codepipeline.main.arn}"
        },
        {
            "Action": "iam:PassRole",
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "trigger-attach" {
  role       = aws_iam_role.trigger-role.name
  policy_arn = aws_iam_policy.trigger-policy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_security_group" "task" {
  name   = "${var.prefix}-task-sg"
  vpc_id = var.vpc_id
  tags   = { Name = "${var.prefix}-task" }
}

resource "aws_security_group_rule" "task-ingress" {
  type                     = "ingress"
  security_group_id        = aws_security_group.task.id
  source_security_group_id = aws_security_group.lb.id
  from_port                = var.target-port
  to_port                  = var.target-port
  protocol                 = "-1"
}

resource "aws_security_group_rule" "task-db-ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.task.id
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
}

resource "aws_security_group_rule" "task-egress" {
  type              = "egress"
  security_group_id = aws_security_group.task.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
