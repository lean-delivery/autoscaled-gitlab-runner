terraform {
  required_version = ">= 1.0"
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.21"
    }
    # gitlab = {
    #   source  = "gitlabhq/gitlab"
    #   version = "~> 17.5"
    # }
  }
}

provider "aws" {
}

# provider "gitlab" {
#   base_url = var.gitlab_api_url
# }

resource "aws_iam_instance_profile" "gitlab_runner" {
  name_prefix = local.stack_name
  role        = var.iam_role
}

resource "aws_launch_template" "gitlab_runner" {
  name                   = local.stack_name
  image_id               = coalesce(var.image_id, data.aws_ami.gitlab_runner.id)
  key_name               = var.key_name
  update_default_version = true

  iam_instance_profile {
    name = aws_iam_instance_profile.gitlab_runner.name
  }

  vpc_security_group_ids = [
    aws_security_group.gitlab_runner.id,
  ]

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      encrypted             = true
      volume_type           = "gp3"
      volume_size           = var.root_disk_size
      delete_on_termination = var.volume_delete_on_termination
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(data.aws_default_tags.tags.tags, { Name = "gitlab-runner-${var.environment_name}" })
  }
  user_data = base64encode(local.instance_userdata)
}

resource "aws_autoscaling_group" "gitlab_runners" {
  name             = local.stack_name
  desired_capacity = var.desired_size
  max_size         = var.max_size
  min_size         = var.min_size

  health_check_grace_period = 5

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_instance_pools                      = 0
      spot_allocation_strategy                 = "price-capacity-optimized"
      on_demand_allocation_strategy            = "lowest-price"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.gitlab_runner.id
        version            = aws_launch_template.gitlab_runner.latest_version
      }

      dynamic "override" {
        for_each = toset(var.fleet_instance_types)
        content {
          instance_type = override.key
        }
      }
    }
  }

  protect_from_scale_in = false

  vpc_zone_identifier = var.private_subnet_ids

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupTotalCapacity",
    "GroupTotalInstances",
  ]
  dynamic "tag" {
    for_each = merge(
      data.aws_default_tags.tags.tags,
      {
        environment_name = var.environment_name,
        Name             = "gitlab-runner-${var.environment_name}"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}
