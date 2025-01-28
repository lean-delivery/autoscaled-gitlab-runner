
resource "aws_autoscaling_lifecycle_hook" "gitlab_runners_stop" {
  name                   = "${local.stack_name}-stop"
  autoscaling_group_name = aws_autoscaling_group.gitlab_runners.name
  default_result         = "ABANDON"
  heartbeat_timeout      = 200
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
}

resource "aws_autoscaling_lifecycle_hook" "gitlab_runners_start" {
  name                   = "${local.stack_name}-start"
  autoscaling_group_name = aws_autoscaling_group.gitlab_runners.name
  default_result         = "ABANDON"
  heartbeat_timeout      = 200
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
}
