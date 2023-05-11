provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "codepipeline" {
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

resource "aws_iam_role_policy_attachment" "codepipeline" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipelineFullAccess"
  role       = aws_iam_role.codepipeline.name
}

resource "aws_codepipeline" "example" {
  name     = "example-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

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
      provider        = "S3"
      version         = "1"
      output_artifacts = ["source"]
      
      configuration = {
        S3Bucket        = var.s3_bucket_name
        S3ObjectKey     = var.source_code_zip_file_key
        PollForSourceChanges = "false"
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
        ProjectName = var.codebuild_project_name
      }
    }
  }
}
