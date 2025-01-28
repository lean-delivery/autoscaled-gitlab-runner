output "api_gateway_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.gitlab_webhook_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.api_gateway_stage_name}/webhook"
}
