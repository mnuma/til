# API Gateway + Lambdaで NOT 統合プロキシ かつ ルート (/) 直下リソース + WAF関連付けを行いたいとき

- api gateway

```hcl
resource "aws_api_gateway_rest_api" "example_api" {
  name        = "${var.env}-example-api"
  description = "API Gateway for ${local.function_name}"
}

# API Keyを作成
resource "aws_api_gateway_api_key" "example_api_key" {
  name    = "${var.env}-example-api-key"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "example_usage_plan" {
  name = "${var.env}-example-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.example_api.id
    stage  = aws_api_gateway_stage.example_stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "example_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.example_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.example_usage_plan.id
}

resource "aws_api_gateway_method" "example_method_get" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  # ルート (/) に対してGETメソッドを作成
  resource_id      = aws_api_gateway_rest_api.example_api.root_resource_id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "example_integration_get" {
  rest_api_id             = aws_api_gateway_rest_api.example_api.id
  resource_id             = aws_api_gateway_rest_api.example_api.root_resource_id
  http_method             = aws_api_gateway_method.example_method_get.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:ap-northeast-1:lambda:path/2015-03-31/functions/${aws_lambda_function.example_function.arn}/invocations"
}

resource "aws_api_gateway_method_response" "example_method_response_200" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  resource_id = aws_api_gateway_rest_api.example_api.root_resource_id
  http_method = aws_api_gateway_method.example_method_get.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "example_integration_response_200" {
  rest_api_id      = aws_api_gateway_rest_api.example_api.id
  resource_id      = aws_api_gateway_rest_api.example_api.root_resource_id
  http_method      = aws_api_gateway_method.example_method_get.http_method
  status_code      = "200"
  content_handling = "CONVERT_TO_TEXT"
}

# account_idの取得
data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "example_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:ap-northeast-1:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.example_api.id}/*/GET/"
}

resource "aws_api_gateway_deployment" "example_deployment" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.example_api.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example_stage" {
  deployment_id = aws_api_gateway_deployment.example_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  stage_name    = "default"
}

resource "aws_wafv2_web_acl_association" "example_waf_association" {
  resource_arn = aws_api_gateway_stage.example_stage.arn
  web_acl_arn  = aws_wafv2_web_acl.example_waf.arn
}

```

- waf


```
resource "aws_wafv2_ip_set" "example_allowed_ips" {
  name               = "${var.env}-allowed-ips-example"
  scope              = "REGIONAL"
  description        = "Allowed IPs for example API"
  ip_address_version = "IPV4"

  addresses = [
    "34.85.43.93/32", ## Example IP
  ]
}

resource "aws_wafv2_web_acl" "example_api_waf" {
  name        = "${var.env}-example-api-waf"
  scope       = "REGIONAL"
  description = "WAF for example API"
  default_action {
    block {} # defaultの挙動をblockに設定
  }

  rule {
    name     = "AllowSpecificIPs"
    priority = 1
    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.example_allowed_ips.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AllowSpecificIPs"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "ExampleAPIWAF"
    sampled_requests_enabled   = true
  }
}
```
