resource "aws_lb" "int" {
  name                             = "${local.cluster_id}-int"
  load_balancer_type               = "network"
  internal                         = true
  subnets                          = aws_subnet.private[*].id
  enable_cross_zone_load_balancing = true

  tags = merge({
    Name = "${local.cluster_id}-int",
  }, local.cluster_tag)

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_lb_target_group" "aint" {
  name                 = "${local.cluster_id}-aint"
  port                 = 6443
  protocol             = "TCP"
  vpc_id               = aws_vpc.cluster.id
  deregistration_delay = 180

  health_check {
    interval            = 30
    port                = "traffic-port"
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_lb_target_group" "sint" {
  name                 = "${local.cluster_id}-sint"
  port                 = 22623
  protocol             = "TCP"
  vpc_id               = aws_vpc.cluster.id
  deregistration_delay = 180

  health_check {
    interval            = 30
    port                = "traffic-port"
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_lb_listener" "aint" {
  load_balancer_arn = aws_lb.int.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.aint.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "sint" {
  load_balancer_arn = aws_lb.int.arn
  port              = 22623
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.sint.arn
    type             = "forward"
  }
}

