resource "aws_codedeploy_app" "example" {
  name = "example-app"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "example" {
  app_name             = aws_codedeploy_app.example.name
  deployment_group_name = "example-deployment-group"
  service_role_arn     = "arn:aws:iam::124288123671:role/awsrolecodedeploy"
}
  artifact_store {
    location = "demopipeline00981"
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
        S3Bucket    = var.s3_bucket_name
        S3ObjectKey = var.source_code_zip_file_key
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

  resource "aws_codepipeline" "example123" {
  name     = "example123"
  role_arn = "arn:aws:iam::124288123671:role/awsrolecodebuld"

  stage {
    name = "Deploy"

    action {
      name = "Deploy"
      category = "Deploy"
      owner = "AWS"
      provider = "CodeDeploy"
      input_artifacts = ["build"]
      configuration = {
        ApplicationName = aws_codedeploy_app.example.name
        DeploymentGroupName = aws_codedeploy_deployment_group.example.deployment_group_name
        DeploymentConfigName = "CodeDeployDefault.OneAtATime"
      }
    }
  }
}

