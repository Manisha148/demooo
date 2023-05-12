resource "aws_codepipeline" "example0" {
  name     = "example0"
  role_arn = "arn:aws:iam::124288123671:role/awsrolecodebuld"

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
        ApplicationName  = var.codedeploy_app_name
        DeploymentGroupName = var.codedeploy_deployment_group_name
      }
    }
  }
}
