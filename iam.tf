resource "aws_iam_role" "terraform_codepipeline_role" {
  name = "terraform-codepipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })
}


data "aws_iam_policy_document" "terraform-cicd-codepipeline-policies" {
  statement {
    sid       = ""
    actions   = ["codestar-connection:UseConnection"]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    sid       = ""
    actions   = ["cloudwatch:*", "s3:*", "codebuild:*"]
    resources = ["*"]
    effect    = "Allow"
  }
}


resource "aws_iam_policy" "allow_codestar_connection" {
  name        = "AllowUseCodeStarConnection"
  description = "Allow CodePipeline to use CodeStar connection"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codestar-connections:UseConnection"
        ],
        Resource = var.codestar_connector_credentials
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_codestar_policy" {
  role       = aws_iam_role.terraform_codepipeline_role.name
  policy_arn = aws_iam_policy.allow_codestar_connection.arn
}


resource "aws_iam_policy" "terraform_codepipeline_policy" {
  name        = "terraform-codepipeline-policy"
  path        = "/"
  description = "CodePipeline policy"
  policy      = data.aws_iam_policy_document.terraform-cicd-codepipeline-policies.json
}

resource "aws_iam_role_policy_attachment" "terraform_codepipeline_attachment" {
  policy_arn = aws_iam_policy.terraform_codepipeline_policy.arn
  role       = aws_iam_role.terraform_codepipeline_role.id
}

resource "aws_iam_role" "terraform_codebuild_role" {
  name = "terraform-codebuild-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}


data "aws_iam_policy_document" "terraform-cicd-codebuild-policies" {
  statement {
    sid       = "1"
    actions   = ["cloudwatch:*", "s3:*", "codebuild:*", "secretsmanager:*", "iam:*"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "terraform_codebuild_policy" {
  name        = "terraform-codebuild-policy"
  path        = "/"
  description = "codebuild policy"
  policy      = data.aws_iam_policy_document.terraform-cicd-codebuild-policies.json
}

resource "aws_iam_role_policy_attachment" "terraform_codebuild_attachment" {
  policy_arn = aws_iam_policy.terraform_codebuild_policy.arn
  role       = aws_iam_role.terraform_codebuild_role.id
}