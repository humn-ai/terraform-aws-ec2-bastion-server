resource "aws_iam_instance_profile" "default" {
  count = module.this.enabled && local.create_instance_profile ? 1 : 0
  name  = module.this.id
  role  = aws_iam_role.default[0].name
  tags  = module.this.tags
}

resource "aws_iam_role" "default" {
  count = module.this.enabled && local.create_instance_profile ? 1 : 0
  name  = module.this.id
  path  = "/"
  tags  = module.this.tags

  assume_role_policy = data.aws_iam_policy_document.default.json
}

resource "aws_iam_role_policy_attachment" "existing_policies" {
  count      = module.this.enabled && length(var.existing_policy_arns) > 0 ? length(var.existing_policy_arns) : 0
  role       = aws_iam_role.default[0].name
  policy_arn = var.existing_policy_arns[count.index]
}


resource "aws_iam_role_policy" "main" {
  count  = module.this.enabled && local.create_instance_profile ? 1 : 0
  name   = module.this.id
  role   = aws_iam_role.default[0].id
  policy = data.aws_iam_policy_document.main.json
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy_document" "main" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetEncryptionConfiguration"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]

    resources = [var.kms_key_arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:GenerateDataKey"
    ]

    resources = ["*"]
  }
}
