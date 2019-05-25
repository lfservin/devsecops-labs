[
  {
    "name": "zap-app",
    "image": "${app_image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/zap-app",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "environment": [
        {"Name": "TEST_TARGET", "Value": "${server_name}"},
        {"Name": "BUCKET_NAME", "Value": "${bucket_name}"}
    ]
  }
]