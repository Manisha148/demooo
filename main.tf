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
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts  = ["build"]
      configuration   = {
        ClusterName   = var.ecs_cluster_name
        ServiceName   = var.ecs_service_name
        ImageTag      = var.docker_image_tag
        ActionMode    = "REPLACE_ON_FAILURE"
        RunOrder      = "1"
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
