resource "aws_codepipeline" "codepipeline" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.pipeline_role.arn
  tags     = var.tags

  artifact_store {
    location = aws_s3_bucket.pipeline_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_alias.eidos_pipeline_key_alias.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.eidos_connection.arn
        FullRepositoryId = var.repository_id
        BranchName       = "main"
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
        ProjectName = var.project_name
      }
    }
  }

  #  stage {
  #    name = "Deploy"
  #
  #    action {
  #      name            = "Deploy"
  #      category        = "Deploy"
  #      owner           = "AWS"
  #      provider        = "CloudFormation"
  #      input_artifacts = ["build_output"]
  #      version         = "1"
  #
  #      configuration = {
  #        ActionMode     = "REPLACE_ON_FAILURE"
  #        Capabilities   = "CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
  #        OutputFileName = "CreateStackOutput.json"
  #        StackName      = var.stack_name
  #        TemplatePath   = "build_output::sam-templated.yaml"
  #      }
  #    }
  #  }
}


