resource "aws_lb" "main" {
  name            = "${var.prefix}-lb"
  subnets         = var.public_subnets_id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "blue" {
  name        = "${var.prefix}-blue"
  port        = var.target-port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "green" {
  name        = "${var.prefix}-green"
  port        = var.target-port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "blue" {
  load_balancer_arn = aws_lb.main.id
  port              = var.listen-port
  protocol          = "HTTP"
  depends_on        = [aws_lb_target_group.blue]

  default_action {
    target_group_arn = aws_lb_target_group.blue.arn
    type             = "forward"
  }
  lifecycle {
    ignore_changes = [default_action]
  }
}

resource "aws_lb_listener" "green" {
  load_balancer_arn = aws_lb.main.id
  port              = var.test-listen-port
  protocol          = "HTTP"
  depends_on        = [aws_lb_target_group.blue]

  default_action {
    target_group_arn = aws_lb_target_group.blue.arn
    type             = "forward"
  }
  lifecycle {
    ignore_changes = [default_action]
  }
}
