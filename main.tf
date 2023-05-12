resource "aws_codebuild_project" "example" {
  name          = var.codebuild_project_name
  description   = "Example CodeBuild project"
  build_timeout = 60
 artifacts {
  type = "S3"
  name = "my-artifacts"
 
}



  source {
    type            = "S3"
    location        = var.s3_bucket_name
    buildspec       = "buildspec.yml"
    insecure_ssl    = false
    report_build_status = true
  }

  environment {
    compute_type  = "BUILD_GENERAL1_SMALL"
    image         = "aws/codebuild/standard:4.0"
    type          = "LINUX_CONTAINER"
    privileged_mode = true
  }

  service_role = "arn:aws:iam::124288123671:role/awsrolecodebuld"

  tags = {
    Environment = "dev"
  }
}

resource "aws_codepipeline" "example" {
  name     = "example"
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
        ProjectName      = aws_codebuild_project.example.name
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
