# Create the Elastic Beanstalk application and environment
resource "aws_elastic_beanstalk_application" "example" {
  name = "example"
}

resource "aws_elastic_beanstalk_environment" "example" {
  name                = "example"
  application         = aws_elastic_beanstalk_application.example.name
  solution_stack_name = "64bit Amazon Linux 2 v5.4.10 running PHP 7.3"
}

# Create the CodePipeline
resource "aws_codepipeline" "example" {
  name = "example"

  artifact_store {
    location = "mybucketmanisha09845"
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
      input_artifacts = ["source"]
      output_artifacts = ["build"]
      configuration   = {
        ProjectName = "example-build"
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
      configuration   = {
        ApplicationName = aws_elastic_beanstalk_application.example.name
        EnvironmentName = aws_elastic_beanstalk_environment.example.name
      }
    }
  }
}

# Create the CodeBuild project
resource "aws_codebuild_project" "example" {
  name          = "example-build"
  source {
    type            = "CODECOMMIT"
    location        = "my-repo"
    git_clone_depth = 1
  }
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type         = "LINUX_CONTAINER"
  }
  service_role = "arn:aws:iam::124288123671:role/awsrolecodebuld"
}
