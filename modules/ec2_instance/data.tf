data "aws_subnet" "instance" {
  id = var.instance_subnet
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "deploy-user-kms-usage" {

  statement {
    sid = "Enable Deploy User Permissions"
    principals {
      type = "AWS"
      identifiers = [ data.aws_caller_identity.current.arn ] 
    }
    actions = ["kms:*"]
    resources = ["*"]
  }
    
}
