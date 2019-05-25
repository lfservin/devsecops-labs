resource "aws_sfn_state_machine" "zap-state-machine" {
  name = "zap-state-machine"
  role_arn = "${aws_iam_role.step-function-security-role.arn}"
  depends_on = ["null_resource.delay", "aws_ecs_task_definition.bandit_app", "aws_subnet.private", "aws_subnet.public"]
  definition = <<EOF
{
  "Comment": "SAST and DAST Step Function Pipeline for CTF2",
  "StartAt": "Run Bandit Fargate Task",
  "TimeoutSeconds": 3600,
  "States": {
    "Run Bandit Fargate Task": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "LaunchType": "FARGATE",
        "Cluster": "${aws_ecs_cluster.main.arn}",
        "TaskDefinition": "${aws_ecs_task_definition.bandit_app.arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "Subnets": ["${aws_subnet.public.0.id}"],
            "AssignPublicIp": "ENABLED"
          }
        }
      },
      "Next": "Notify Success Bandit",
      "Catch": [
        {
          "ErrorEquals": [ "States.ALL" ],
          "Next": "Notify Failure Bandit"
        }
      ]
    },
    "Notify Success Bandit": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "Message": "Bandit Run Successfully Completed",
        "TopicArn": "${aws_sns_topic.ctf2-status-topic.arn}"
      },
      "Next": "Run ZAP Fargate Task"
    },
    "Notify Failure Bandit": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "Message": "Bandit run failed",
        "TopicArn": "${aws_sns_topic.ctf2-status-topic.arn}"
      },
      "Next": "Run ZAP Fargate Task"
    },
    "Run ZAP Fargate Task": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask.sync",
      "Parameters": {
        "LaunchType": "FARGATE",
        "Cluster": "${aws_ecs_cluster.main.arn}",
        "TaskDefinition": "${aws_ecs_task_definition.app.arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "Subnets": ["${aws_subnet.public.0.id}"],
            "AssignPublicIp": "ENABLED"
          }
        }
      },
      "Next": "Notify Success",
      "Catch": [
        {
          "ErrorEquals": [ "States.ALL" ],
          "Next": "Notify Failure"
        }
      ]
    },
    "Notify Success": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "Message": "ZAP Ctf2 Run successfully completed",
        "TopicArn": "${aws_sns_topic.ctf2-status-topic.arn}"
      },
      "End": true
    },
    "Notify Failure": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "Message": "ZAP-CTF2 Run Failed",
        "TopicArn": "${aws_sns_topic.ctf2-status-topic.arn}"
      },
      "End": true
    }
  }
}
EOF
}