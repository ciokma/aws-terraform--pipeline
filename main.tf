terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}


resource "aws_codepipeline" "codepipeline" {
    name     = var.aws_codepipeline_name
    role_arn = aws_iam_role.codepipeline_role.arn
    artifact_store {
        location = aws_s3_bucket.codepipeline_bucket.bucket
        type     = "S3"
    }

    stage {
        name = "Source"

        action {
            name             = "Source"
            category         = "Source"
            owner            = "AWS"
            provider         = "CodeCommit"
            version          = "1"
            output_artifacts = ["source_output"]
            configuration = {
                RepositoryName = "sam-cicd-terraform"
                BranchName     = "master"
                
            }
        }
    }

    stage {
        name = "Build"

        action {
            name             = "Build"
            category         = "Build"
            owner            = "AWS"
            provider         = "CodeBuild"
            input_artifacts  = ["source_output"]
            output_artifacts = ["build_output"]
            version          = "1"

            configuration = {
                ProjectName = var.aws_codebuild_name
            }
        }
    }
    stage {
        name = "Manual_Approval"

        action {
            name     = "Manual-Approval"
            category = "Approval"
            owner    = "AWS"
            provider = "Manual"
            version  = "1"
        }
    }

    stage {
        name = "Deploy"

        action {
            name            = "CreateChangeSet"
            category        = "Deploy"
            owner           = "AWS"
            provider        = "CloudFormation"
            input_artifacts = ["build_output"]
            role_arn        = aws_iam_role.cloudformation.arn
            version         = 1
            run_order = 1

            configuration = {
                ActionMode     = "CHANGE_SET_REPLACE"
                Capabilities   = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
                OutputFileName = "CreateStackOutput.json"
                RoleArn        =  aws_iam_role.cloudformation.arn
                StackName      = var.stack_name
                TemplatePath   = "build_output::packaged-template.yml"
                ChangeSetName  = "${var.stack_name}-deploy"
                # TemplateConfiguration = "build::configuration.json"

            }
        }

         action {
            name            = "ExcuteChangeset"
            category        = "Deploy"
            owner           = "AWS"
            provider        = "CloudFormation"
            input_artifacts = ["build_output"]
            version         = "1"
            run_order = 2

            configuration = {
                ActionMode     = "CHANGE_SET_EXECUTE"
                Capabilities   = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
                OutputFileName = "ChangeSetExecuteOutput.json"
                StackName      = var.stack_name
                ChangeSetName  = "${var.stack_name}-deploy"
            }
        }
    }
}
