provider "aws" {
  region = "us-east-1"
}

resource "aws_elastic_beanstalk_application" "example" {
  name        = "example-app"
  description = "Example Elastic Beanstalk Application"
}

resource "aws_elastic_beanstalk_environment" "example" {
  name                = "example-env"
  application         = aws_elastic_beanstalk_application.example.name
  solution_stack_name = "64bit Amazon Linux 2 v5.4.3 running PHP 7.4"
}

resource "aws_iam_role" "example" {
  name = "example-codepipeline-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess"
  role       = aws_iam_role.example.name
}

resource "aws_codebuild_project" "example" {
  name          = "example-build"
  service_role  = aws_iam_role.example.arn
  timeout_in_minutes = 60

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "buildspec.yml"
    report_build_status = true
  }
}

resource "aws_codepipeline" "example" {
  name     = "example"
  role_arn = aws_iam_role.example.arn

  artifact_store {
    location = "s3://${var.s3_bucket_name}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name            = "Source"
      category        = "Source"
      owner           = "AWS"
      provider        = "CodeCommit"
      version         = "1"
      output_artifacts = ["source"]
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["build"]
      configuration   = {
        ProjectName      = aws_codebuild_project.example.name
        EnvironmentVariables = {
          "APPLICATION_NAME" = aws_elastic_beanstalk_application.example.name
          "ENVIRONMENT_NAME" = aws_elastic_beanstalk_environment.example.name
        }
      }
    }
  }
stage {
  name = "Deploy"

  action {
    name            = "Deploy"
    category        = "Deploy"
    owner           = "AWS"
    provider        = "ElasticBeanstalk"
    version         = "1"
    input_artifacts = ["build"]
    ...
  }
}

  
