resource "aws_api_gateway_rest_api" "gitlab_webhook_api" {
  name        = local.stack_name
  description = "API Gateway to receive GitLab webhooks and trigger Step Functions"
}

resource "aws_api_gateway_resource" "webhook_resource" {
  rest_api_id = aws_api_gateway_rest_api.gitlab_webhook_api.id
  parent_id   = aws_api_gateway_rest_api.gitlab_webhook_api.root_resource_id
  path_part   = "webhook"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.gitlab_webhook_api.id
  resource_id   = aws_api_gateway_resource.webhook_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/aws/api-gateway/${aws_api_gateway_rest_api.gitlab_webhook_api.id}"
  retention_in_days = 14
}

resource "aws_iam_role" "api_gateway_role" {
  name = "${local.stack_name}-apigatewayrole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "api_gateway_logs_policy" {
  name        = "${local.stack_name}-APIGatewayLogsPolicy"
  description = "Permissions for API Gateway to write logs to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the API Gateway role
resource "aws_iam_role_policy_attachment" "api_gateway_logs_policy_attachment" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.api_gateway_logs_policy.arn
}

resource "aws_iam_policy" "api_gateway_policy" {
  name        = "${local.stack_name}-apigatewaypolicy"
  description = "Permissions for API Gateway to invoke Step Functions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowInvokeStepFunctions"
        Effect   = "Allow"
        Action   = "states:StartExecution"
        Resource = aws_sfn_state_machine.state_machine.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_role_policy_attachment" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.api_gateway_policy.arn
}

locals {
  request_templates = {
    "application/json" = jsonencode(
      {
        input           = "{\"body\": $util.escapeJavaScript($input.json('$.build_status')), \"head\": \"$util.escapeJavaScript($input.params().header.get('X-Gitlab-Token'))\"}"
        stateMachineArn = "$util.escapeJavaScript($stageVariables.arn)"
      }
    )
  }
}

resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_role.arn

  depends_on = [
    aws_iam_role_policy_attachment.api_gateway_logs_policy_attachment
  ]
}

resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.gitlab_webhook_api.id
  resource_id             = aws_api_gateway_resource.webhook_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:states:action/StartExecution"
  credentials             = aws_iam_role.api_gateway_role.arn
  request_templates       = local.request_templates
  passthrough_behavior    = "NEVER"
}

resource "aws_api_gateway_method_response" "post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.gitlab_webhook_api.id
  resource_id = aws_api_gateway_resource.webhook_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.gitlab_webhook_api.id
  resource_id = aws_api_gateway_resource.webhook_resource.id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = aws_api_gateway_method_response.post_method_response.status_code
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.post_integration]
  rest_api_id = aws_api_gateway_rest_api.gitlab_webhook_api.id
}

resource "aws_api_gateway_stage" "api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.gitlab_webhook_api.id
  stage_name    = var.api_gateway_stage_name
  deployment_id = aws_api_gateway_deployment.api_deployment.id

  variables = {
    arn = aws_sfn_state_machine.state_machine.arn
  }
  xray_tracing_enabled = true
}

resource "aws_api_gateway_method_settings" "api_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.gitlab_webhook_api.id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = false
    logging_level   = "INFO"
  }
}
