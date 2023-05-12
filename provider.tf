variable "s3_bucket_name" {
  type = string
}

variable "source_code_zip_file_key" {
  type = string
}

variable "codebuild_project_name" {
  type = string
}
variable "codedeploy_app_name" {
  type    = string
  default = "my-codedeploy-app"
}
variable "codedeploy_service_role_arn" {
  type = string
}
