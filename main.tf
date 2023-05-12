resource "aws_codedeploy_app" "example" {
  name = "example"
}

resource "aws_codedeploy_deployment_group" "example" {
  name                   = "example"
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  app_name               = aws_codedeploy_app.example.name

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}

resource "aws_codepipeline" "example" {
  name     = "example"
  role_arn = "arn:aws:iam::123456789012:role/CodePipelineServiceRole"

  artifact_store {
    location = "example-artifacts"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name            = "Source"
      category        = "Source"
      owner           = "AWS"
      provider        = "S3"
      version         = "1"
      output_artifacts = ["source"]

      configuration = {
        S3Bucket    = var.source_bucket_name
        S3ObjectKey = var.source_object_key
      }
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
        ProjectName      = var.codebuild_project_name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts  = ["build"]
      configuration   = {
        ApplicationName  = aws_codedeploy_app.example.name
        DeploymentGroupName = aws_codedeploy_deployment_group.example.name
      }
    }
  }
}
