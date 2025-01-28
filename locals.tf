locals {
  stack_name         = "glab-runner-${var.environment_name}"

  extravars = {
    for k, v in {
      gl_concurrency        = var.capacity_per_instance,
      gl_runner_docker_tags = var.gl_runner_tags,
      gl_cache_path         = var.gl_cache_path,
      gl_group_id           = var.group_id,
      gl_cache_bucket       = "glab-runner-${var.environment_name}",
      gl_bucket_location    = var.aws_region,
    } : k => v if v != null
  }
  instance_userdata = templatefile("templates/user_data.tmpl", {
    extravars      = yamlencode(local.extravars),
    idle_threshold = var.idle_threshold,
    ami_user       = var.ami_user,
    aws_region     = var.aws_region,
    gitlab_config  = try(file("${path.root}/files/gitlab_config.yaml"), ""),
  })
}
