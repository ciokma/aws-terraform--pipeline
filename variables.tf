variable "region" {
  type = string
  description = "The region to launch the infrastructure"
  default = "us-east-1"
}
variable "s3_bucket" {
  type = string
  description = "enter the unique name for s3 bucket. If you don't give unqie name, terraform fails creating infrastructure."
  default = "cicd-app-terraform-demo"
}
variable "codecommit_branch" {
  type = string
  description = "enter the unique name for branch of codecommit."
  default = "master"
}


variable "aws_codebuild_name" {
  type = string
  description = "Enter the name for codebuild project"
  default = "react-codebuild-1"
}
variable "aws_codepipeline_name" {
  type = string
  description = "Enter the name for codepipeline project"
  default = "tf-codepipeline"
}


variable "cloudwatch_group_name" {
  type = string
  description = "The name of the cloudwatch group to group logs"
  default = "react-codepipeline-logs"
}

variable "cloudwatch_stream_name" {
  type = string
  description = "The name of the cloudwatch stream"
  default = "react-codepipeline-stream"
}



variable "stack_name" {
  type = string
  description = "the cloudformation stack name, could be the funcion lambda name"
  default = "lambda-demo-pipeline"
}

