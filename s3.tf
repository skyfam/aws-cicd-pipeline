resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "terraform-cicd-aws-pipeline-artifacts"
}