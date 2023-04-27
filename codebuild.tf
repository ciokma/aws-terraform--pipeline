
resource "aws_codebuild_project" "codebuild" {
  name          = var.aws_codebuild_name
  description   = "test_codebuild_project"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
//    location = aws_s3_bucket.codepipeline_bucket.bucket
    location = var.s3_bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.cloudwatch_group_name
      stream_name = var.cloudwatch_stream_name
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.codepipeline_bucket.id}/build-log"
    }
  }

  source {
    type      = "CODECOMMIT"
    location = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/sam-cicd-terraform"
  }


  source_version = var.codecommit_branch
}