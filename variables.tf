variable "gitlab_api_url" {
  type        = string
  sensitive   = true
  default     = "https://gitlab.com/api/v4/"
  description = "Target GitLab base API endpoint in the form of `https://my.gitlab.server/api/v4/`."
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default = "172.31.0.0/16"
}

variable "bastion_security_group_id" {
  description = "The ID of the bastion security group."
  type        = string
  default = "sg-0a1b2c3d4e5f6g7h8"
}

variable "ami_user" {
  description = "The user to use for the AMI."
  type        = string
  default     = "ec2-user"
}

variable "aws_region" {
  description = "The AWS region to use."
  type        = string
}

variable "environment_name" {
  description = "The name of the environment."
  type        = string
}

# variable "architecture" {
#   description = "An image's architecture. Can be x86_64 or arm64."
#   default     = "x86_64"
#   type        = string
# }

variable "api_gateway_stage_name" {
  description = "Name of the API Gateway deployment stage"
  default     = "dev"
  type        = string
}

variable "image_id" {
  description = "If unset or false (default), use the data lookup for the image"
  default     = null
  type        = string
}

variable "image_name" {
  description = "The 'service_name' of the image to lookup"
  default     = "gitlab-runner-amazon"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use."
  default     = "gitlab-runner-key"
  type        = string
}

# variable "ecr_url" {
#   description = "The ECR URL for the Docker image."
#   type        = string
#   default     = "docker.io"
# }

# variable "docker_image_name" {
#   description = "The name of the Docker image to use."
#   type        = string
#   default     = "docker"
# }

# variable "docker_image_tag" {
#   description = "The tag of the Docker image to use."
#   type        = string
#   default     = "latest"
# }

variable "iam_role" {
  description = "The IAM role to use for the instances."
  type        = string
  default     = "gitlab-runner"
}

variable "fleet_instance_types" {
  description = "The instance types to use."
  type        = list(string)
  default = [
    "m5a.large",
    "m5.large",
    "m6a.large",
    "m6i.large",
    "m7a.large",
    "c5.large",
    "c5a.large",
    "c6a.large",
    "c6i.large",
    "c7i.large",
    "c7a.large",
    "m7i.large",
    "m7i-flex.large"
  ]
}

variable "private_subnet_ids" {
  description = "List of subnet IDs to launch resources in."
  type        = list(string)
  default = [
  "subnet-0a1b2c3d4e5f6g7h8",
  ]
}

variable "root_disk_size" {
  description = "The size of the root disk in GB."
  type        = number
  default     = 30
}

variable "volume_delete_on_termination" {
  description = "Whether to delete the root volume on instance termination."
  type        = bool
  default     = true
}

variable "min_size" {
  description = "The minimum number of instances in the autoscaling group."
  type        = number
  default     = 0
}
variable "max_size" {
  description = "The maximum number of instances in the autoscaling group."
  type        = number
  default     = 10
}
variable "desired_size" {
  description = "The desired number of instances in the autoscaling group."
  type        = number
  default     = 0
}
variable "capacity_per_instance" {
  description = "The number of concurrent jobs per instance."
  type        = number
  default     = null
}

variable "gl_runner_tags" {
  description = "The tags to apply to the GitLab Runner."
  type        = list(string)
  default     = null
}

variable "group_id" {
  description = "The GitLab group ID."
  type        = number
  default     = 1347 # platformservices group id
}

variable "gl_cache_path" {
  description = "The IAM role to use for the instances."
  type        = string
  default     = "cache"
}

variable "idle_threshold" {
  description = "The number of seconds before a runner is considered idle."
  type        = number
  default     = null
}

variable "gitlab_secret_token" {
  description = "Secret token configured in GitLab webhook for validation"
  type        = string
  default     = "h&s8BdSbinDQ7h"
}
