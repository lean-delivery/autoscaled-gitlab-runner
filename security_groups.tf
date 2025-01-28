resource "aws_security_group" "gitlab_runner" {
  name        = "${local.stack_name}-runner"
  description = "SSH access to the GitLab Runner."
  vpc_id      = var.vpc_id
  tags        = { Name = "gitlab-runner" }
}

resource "aws_vpc_security_group_ingress_rule" "runner_ssh" {
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.gitlab_runner.id
  referenced_security_group_id = var.bastion_security_group_id
  description                  = "Access from the bastion."
  tags                         = { Name = "bastion_to_runner" }
}

resource "aws_vpc_security_group_egress_rule" "runner_to_https" {
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.gitlab_runner.id
  description       = "External HTTPS access."
  tags              = { Name = "runner_to_https" }
}
resource "aws_vpc_security_group_egress_rule" "runner_to_ssh" {
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
  security_group_id = aws_security_group.gitlab_runner.id
  description       = "External SSH access."
  tags              = { Name = "runner_to_ssh" }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.gitlab_runner.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow external access."
  tags              = { Name = "gitlab_runner_to_external" }
}
