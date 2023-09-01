terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_cloudwatch_event_rule" "console" {
  name = "capture_aws_activity"

  event_pattern = <<EOT
  {
    "source": ["aws.ec2", "aws.s3"]
  }
  EOT
}

resource "aws_sns_topic" "aws_activity" {
  name = "aws-console-activity"
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.console.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.aws_activity.arn
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.aws_activity.arn
  protocol  = "email"
  endpoint  = "yourmail@gmail.com"
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.aws_activity.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}