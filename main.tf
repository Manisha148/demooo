resource "aws_codepipeline" "example" {
  name     = "example"
  role_arn = "arn:aws:iam::124288123671:role/awsrolecodebuld"

  artifact_store {
    location = "s3://${var.mycform}"
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

      configuration = {
        ApplicationName         = aws_elastic_beanstalk_application.example.name
        EnvironmentName         = aws_elastic_beanstalk_environment.example.name
        DeploymentCommand       = "eb deploy"
        DeploymentTimeoutInMinutes = "5"
        IgnoreApplicationStopFailures = "true"
      }
    }
  }
}
