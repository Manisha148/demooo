variable "s3_bucket_name" {
  type = string
}

variable "source_code_zip_file_key" {
  type = string
}

variable "codebuild_project_name" {
  type = string
}
variable "ecs_cluster_name" {
  type    = string
  default = "my-ecs-cluster"
}

variable "ecs_service_name" {
  type    = string
  default = "my-ecs-service"
}

variable "docker_image_tag" {
  type    = string
  default = "latest"
}
