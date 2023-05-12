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
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts  = ["build"]
      configuration   = {
        ApplicationName  = var.codedeploy_application_name
        DeploymentGroupName = var.codedeploy_deployment_group_name
      }

      run_order = 1
    }
  }
}

resource "aws_iam_role" "codedeploy_ec2_role" {
  name = "codedeploy-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRoleForEC2"
  role       = aws_iam_role.codedeploy_ec2_role.name
}

resource "aws_codedeploy_deployment_group" "example" {
  name                = var.codedeploy_deployment_group_name
  service_role_arn    = aws_iam_role.codedeploy_ec2_role.arn
  deployment_config_name = var.codedeploy_deployment_config_name

  ec2_tag_set {
    tag_filter_type = "KEY_AND_VALUE"

    tag_filter {
      key   = "Name"
      value = var.ec2_instance_name
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
