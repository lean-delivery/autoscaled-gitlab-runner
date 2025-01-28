# autoscaled-gitlab-runner
GitLab Runner fleet on AWS using the GitLab Runner and AWS Autoscaling services.

For more details, refer to the [Solution Overview](docs/overview.md).

The terraform stack includes the following components:

* GitLab Job Webhook:
    - Triggers the Step Functions workflow whenever new CI/CD jobs are added to the queue.
* Amazon DynamoDB:
    - Used for state management and lock acquisition.
    - Ensures that scaling operations are not duplicated or run concurrently.
* AWS Step Function:
    - Manages workflow to process incoming requests from Gitlab Job Webhook and execute scaling action if required.
* Auto Scaling Group (ASG):
    - Dynamically adjusts the number of GitLab Runner instances based on job demand.
* CloudWatch:
    - Monitors metrics from the runner to analyze servers load and performance
* IAM Roles:
    - Secures interactions between services.

## Prerequisites

Before using this stack, ensure you have the following AMI must be available in the target region: `gitlab-runner-amazon`.

AMI can be built using the following command:

```bash
ansible-playbook ami_build.yml -e @aws_vars.yml
```

Before building the AMI you need the following secrets to be configured:
* `gl_runner_token` secret string stored in AWS Parameters Store, path: `/gitlab_tokens`

This secret is used to register new gitlab-runner instances in Gitlab on EC2 instance startup during execution of user-metadata scripts.

* `gitlab_secret_token` secret stored in secrets or specified explicitly as terraform variable

This secret is used to secure API calls from Gitlab Webhook to AWS API Gateway triggering Step Function to scale AWS Autoscaling Group on demand.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.21 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.84.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_account.api_gateway_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account) | resource |
| [aws_api_gateway_deployment.api_deployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_integration.post_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.post_integration_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.post_method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.post_method_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_settings.api_method_settings](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_resource.webhook_resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.gitlab_webhook_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.api_stage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_autoscaling_group.gitlab_runners](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_lifecycle_hook.gitlab_runners_start](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_lifecycle_hook) | resource |
| [aws_autoscaling_lifecycle_hook.gitlab_runners_stop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_lifecycle_hook) | resource |
| [aws_cloudwatch_log_group.api_gw_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.step_functions_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_dynamodb_table.lock_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_instance_profile.gitlab_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.api_gateway_logs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.api_gateway_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.gitlab_cache_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.step_functions_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.api_gateway_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.step_functions_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.api_gateway_logs_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.api_gateway_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.gitlab_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.step_functions_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.gitlab_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_s3_bucket.gitlab_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_security_group.gitlab_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_sfn_state_machine.state_machine](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.runner_to_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.runner_to_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.runner_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_ami.gitlab_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_default_tags.tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.gitlab_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gitlab_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_user"></a> [ami\_user](#input\_ami\_user) | The user to use for the AMI. | `string` | `"ec2-user"` | no |
| <a name="input_api_gateway_stage_name"></a> [api\_gateway\_stage\_name](#input\_api\_gateway\_stage\_name) | Name of the API Gateway deployment stage | `string` | `"dev"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to use. | `string` | n/a | yes |
| <a name="input_bastion_security_group_id"></a> [bastion\_security\_group\_id](#input\_bastion\_security\_group\_id) | The ID of the bastion security group. | `string` | `"sg-0a1b2c3d4e5f6g7h8"` | no |
| <a name="input_capacity_per_instance"></a> [capacity\_per\_instance](#input\_capacity\_per\_instance) | The number of concurrent jobs per instance. | `number` | `null` | no |
| <a name="input_desired_size"></a> [desired\_size](#input\_desired\_size) | The desired number of instances in the autoscaling group. | `number` | `0` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | The name of the environment. | `string` | n/a | yes |
| <a name="input_fleet_instance_types"></a> [fleet\_instance\_types](#input\_fleet\_instance\_types) | The instance types to use. | `list(string)` | <pre>[<br/>  "m5a.large",<br/>  "m5.large",<br/>  "m6a.large",<br/>  "m6i.large",<br/>  "m7a.large",<br/>  "c5.large",<br/>  "c5a.large",<br/>  "c6a.large",<br/>  "c6i.large",<br/>  "c7i.large",<br/>  "c7a.large",<br/>  "m7i.large",<br/>  "m7i-flex.large"<br/>]</pre> | no |
| <a name="input_gitlab_api_url"></a> [gitlab\_api\_url](#input\_gitlab\_api\_url) | Target GitLab base API endpoint in the form of `https://my.gitlab.server/api/v4/`. | `string` | `"https://gitlab.com/api/v4/"` | no |
| <a name="input_gitlab_secret_token"></a> [gitlab\_secret\_token](#input\_gitlab\_secret\_token) | Secret token configured in GitLab webhook for validation | `string` | `"h&s8BdSbinDQ7h"` | no |
| <a name="input_gl_cache_path"></a> [gl\_cache\_path](#input\_gl\_cache\_path) | The IAM role to use for the instances. | `string` | `"cache"` | no |
| <a name="input_gl_runner_tags"></a> [gl\_runner\_tags](#input\_gl\_runner\_tags) | The tags to apply to the GitLab Runner. | `list(string)` | `null` | no |
| <a name="input_group_id"></a> [group\_id](#input\_group\_id) | The GitLab group ID. | `number` | `1347` | no |
| <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role) | The IAM role to use for the instances. | `string` | `"gitlab-runner"` | no |
| <a name="input_idle_threshold"></a> [idle\_threshold](#input\_idle\_threshold) | The number of seconds before a runner is considered idle. | `number` | `null` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | If unset or false (default), use the data lookup for the image | `string` | `null` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | The 'service\_name' of the image to lookup | `string` | `"gitlab-runner-amazon"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The name of the key pair to use. | `string` | `"gitlab-runner-key"` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum number of instances in the autoscaling group. | `number` | `10` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum number of instances in the autoscaling group. | `number` | `0` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of subnet IDs to launch resources in. | `list(string)` | <pre>[<br/>  "subnet-0a1b2c3d4e5f6g7h8"<br/>]</pre> | no |
| <a name="input_root_disk_size"></a> [root\_disk\_size](#input\_root\_disk\_size) | The size of the root disk in GB. | `number` | `30` | no |
| <a name="input_volume_delete_on_termination"></a> [volume\_delete\_on\_termination](#input\_volume\_delete\_on\_termination) | Whether to delete the root volume on instance termination. | `bool` | `true` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block for the VPC. | `string` | `"172.31.0.0/16"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_gateway_invoke_url"></a> [api\_gateway\_invoke\_url](#output\_api\_gateway\_invoke\_url) | n/a |
<!-- END_TF_DOCS -->