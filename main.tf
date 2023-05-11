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
        ProjectName      = var.codebuild_project_name
      }
    }
  }

   stage {
    name = "Deploy"

    action {
      name = "DeployAction"
      category = "Deploy"
      owner = "AWS"
      provider = "CodeDeploy"
      input_artifacts = ["build"]
      configuration = {
        DeploymentGroupName = aws_codedeploy_deployment_group.example.name
        AppSpecTemplate = file("appspec.yml")
      }
    }
  }
}




# resource "aws_codepipeline" "example" {
#   name     = "example"
#   role_arn = "arn:aws:iam::124288123671:role/awsrolecodebuld"

#   artifact_store {
#     location = "demopipeline00981"
#     type     = "S3"
#   }

#   stage {
#     name = "Source"

#     action {
#       name            = "Source"
#       category        = "Source"
#       owner           = "AWS"
#       provider        = "S3"
#       version         = "1"
#       output_artifacts = ["source"]

#       configuration = {
#         S3Bucket    = var.s3_bucket_name
#         S3ObjectKey = var.source_code_zip_file_key
#       }
#     }
#   }

#   stage {
#     name = "Build"

#     action {
#       name            = "Build"
#       category        = "Build"
#       owner           = "AWS"
#       provider        = "CodeBuild"
#       version         = "1"
#       input_artifacts  = ["source"]
#       output_artifacts = ["build"]
#       configuration   = {
#         ProjectName      = var.codebuild_project_name
#       }
#     }
#   }
# }
