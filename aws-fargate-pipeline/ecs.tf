provider "aws" {
  region     = "${var.aws_region}"
}


resource "aws_ecs_cluster" "main" {
  name = "security-test-cluster"
}

data "template_file" "zap_app" {
  template = "${file("templates/ecs/cb_app.json.tpl")}"

  vars {
    app_image      = "${var.app_image}"
    fargate_cpu    = "${var.fargate_cpu}"
    fargate_memory = "${var.fargate_memory}"
    aws_region     = "${var.aws_region}"
    server_name    = "${var.server-name}"
    bucket_name    = "${aws_s3_bucket.ecs-file-bucket.bucket}"
  }

  depends_on = ["aws_s3_bucket.ecs-file-bucket"]
}

data "template_file" "bandit_app" {
  template = "${file("templates/ecs/bandit_app.json.tpl")}"

  vars {
    app_image = "we45/ctf2_bandit"
    fargate_cpu    = "${var.fargate_cpu}"
    fargate_memory = "${var.fargate_memory}"
    aws_region     = "${var.aws_region}"
    bucket_name    = "${aws_s3_bucket.ecs-file-bucket.bucket}"    
  }
}

resource "random_id" "bucket_name" {
  byte_length = 8
}

resource "aws_s3_bucket" "ecs-file-bucket" {
  bucket = "${random_id.bucket_name.hex}-zap-results"
}


resource "aws_ecs_task_definition" "app" {
  family                   = "zap-app-task"
  task_role_arn            = "${aws_iam_role.tes_role.arn}"
  execution_role_arn       = "${aws_iam_role.tes_role.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  container_definitions    = "${data.template_file.zap_app.rendered}"
}

resource "aws_ecs_task_definition" "bandit_app" {
  family                   = "bandit-app-task"
  task_role_arn            = "${aws_iam_role.tes_role.arn}"
  execution_role_arn       = "${aws_iam_role.tes_role.arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  container_definitions    = "${data.template_file.bandit_app.rendered}"
}


resource "aws_cloudwatch_log_group" "zap_log_group" {
  name              = "/ecs/zap-app"
  retention_in_days = 30

  tags {
    Name = "zap-log-group"
  }
}

resource "aws_cloudwatch_log_group" "bandit_log_group" {
  name              = "/ecs/bandit-app"
  retention_in_days = 30

  tags {
    Name = "bandit-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "zap_log_stream" {
  name           = "zap-log-stream"
  log_group_name = "${aws_cloudwatch_log_group.zap_log_group.name}"
}

resource "aws_cloudwatch_log_stream" "bandit_log_stream" {
  name           = "bandit-log-stream"
  log_group_name = "${aws_cloudwatch_log_group.bandit_log_group.name}"
}

resource "aws_ssm_parameter" "ctf2-login-email" {
  name = "ctf2_login_email"
  type = "SecureString"
  value = "bruce.banner@we45.com"
}

resource "aws_ssm_parameter" "ctf2-login-pwd" {
  name = "ctf2_login_pwd"
  type = "SecureString"
  value = "secdevops"
}

resource "aws_sns_topic" "ctf2-status-topic" {
  name = "ctf2-status-topic"
}


resource "aws_iam_role_policy" "bad-role-policy" {
  role = "${aws_iam_role.tes_role.id}"
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
	{
		"Action": [
          "s3:*"
		],
		"Effect": "Allow",
		"Resource": ["${aws_s3_bucket.ecs-file-bucket.arn}/*"]
	},
    {
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
		],
		"Effect": "Allow",
		"Resource": "arn:aws:logs:*:*:*"
	},
    {
        "Action": [
          "ecr:GetAuthorizationToken"
		],
		"Effect": "Allow",
		"Resource": "*"
	},
    {
        "Action": [
          "ssm:*"
		],
		"Effect": "Allow",
		"Resource": "arn:aws:ssm:${var.aws_region}:*:*"
	},
    {
        "Action": [
          "sns:Publish"
		],
		"Effect": "Allow",
		"Resource": "${aws_sns_topic.ctf2-status-topic.arn}"
	}
	]
}
EOF
}


resource "random_id" "ecs_role_id" {
  byte_length = 8
}

resource "aws_iam_role" "tes_role" {
  name = "${random_id.ecs_role_id.hex}-ecs-zap-task-exec-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "random_id" "role_id" {
  byte_length = 8
}

resource "aws_iam_role" "step-function-security-role" {
  name = "${random_id.role_id.hex}-step-function-security-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "states.${var.aws_region}.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "security-step-func-policy" {
  role = "${aws_iam_role.step-function-security-role.id}"
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
	{
		"Action": [
          "ecs:RunTask"
		],
		"Effect": "Allow",
		"Resource": ["${aws_ecs_task_definition.app.arn}", "${aws_ecs_task_definition.bandit_app.arn}"]

	},
    {
        "Action": [
          "ecs:StopTask",
          "ecs:DescribeTasks"
		],
		"Effect": "Allow",
		"Resource": "*"
	},
    {
        "Action": [
          "events:PutTargets",
          "events:PutRule",
          "events:DescribeRule"
		],
		"Effect": "Allow",
		"Resource": "*"
	},
    {
        "Action": [
          "sns:Publish"
		],
		"Effect": "Allow",
		"Resource": "${aws_sns_topic.ctf2-status-topic.arn}"
	},
    {
        "Action": [
          "iam:PassRole"
		],
		"Effect": "Allow",
		"Resource": "${aws_iam_role.tes_role.arn}"
	}
	]
}
EOF
}

resource "null_resource" "delay" {
 provisioner "local-exec" {
   command = "sleep 30"
 }
 triggers = {
   "states_exec_role" = "${aws_iam_role.step-function-security-role.arn}"
 }
}