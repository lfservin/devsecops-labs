provider "aws" {
  region = "${var.aws_region}"
}

resource "random_id" "bucket_name" {
  byte_length = 8
}

resource "aws_s3_bucket" "releases" {
  bucket = "${random_id.bucket_name.hex}-pipeline-results"
  acl    = "private"
  force_destroy = true
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codebuild.amazonaws.com",
          "codepipeline.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = "${aws_iam_role.codebuild_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.releases.arn}",
        "${aws_s3_bucket.releases.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"        
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_codebuild_project" "project" {
  name          = "PythonPipeline"
  description   = "PythonPipeline CodeBuild Project"
  build_timeout = "10"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "python:2.7-alpine3.9"
    type         = "LINUX_CONTAINER"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

} 


resource "aws_codepipeline" "project" {
  name     = "python-pipeline"
  role_arn = "${aws_iam_role.codebuild_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.releases.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["code"]

      configuration {
        Owner                = "${var.git_owner}"
        Repo                 = "${var.git_repo}"        
        Branch               = "${var.git_branch}"   
        OAuthToken           = "${var.git_oauth}"     
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["code"]
      output_artifacts  = ["results"]
      version          = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.project.name}"
      }
    }
  }
    
}
