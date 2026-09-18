# ────────────────────────────────────────────────────────────────────
# ECR Resources
# ────────────────────────────────────────────────────────────────────

# ─── ECR Repositories ──────────────────────────────────────────────
resource "aws_ecr_repository" "this" {
  for_each = var.ecr

  # ─── Repository Configuration ─────────────────────────────────────
  name                 = each.value.name
  image_tag_mutability = each.value.image_tag_mutability

  # ─── Image Scanning Configuration ────────────────────────────────
  dynamic "image_scanning_configuration" {
    for_each = each.value.image_scanning_configuration != null ? [each.value.image_scanning_configuration] : []

    content {
      scan_on_push = image_scanning_configuration.value.scan_on_push
    }
  }

  # ─── Tags ───────────────────────────────────────────────────────
  tags = var.tags
}

# ─── ECR Lifecycle Policies ────────────────────────────────────────
# resource "aws_ecr_lifecycle_policy" "this" {
#   for_each = {
#   for key, repo in aws_ecr_repository.this : key => repo
#   if can(var.ecr[key].lifecycle_policy) && var.ecr[key].lifecycle_policy.enabled
#   }


#   # ─── Policy Configuration ────────────────────────────────────────
#   repository = each.value.name

#   policy = jsonencode({
#     rules = [
#       # Rule 1: Clean up untagged images
#       {
#         rulePriority = 1
#         description  = "Remove all untagged images"
#         selection = {
#           tagStatus   = "untagged"
#           countType   = "imageCountMoreThan"
#           countNumber = 1
#         }
#         action = {
#           type = "expire"
#         }
#       },
#       # Rule 2: Retain only latest N tagged images
#       {
#         rulePriority = 2
#         description  = "Retain only the latest tagged images"
#         selection = {
#           tagStatus   = "tagged"
#           tagPatternList  = ["*"]
#           countType   = "imageCountMoreThan"
#           countNumber = var.ecr[each.key].lifecycle_policy.retain_count
#         }
#         action = {
#           type = "expire"
#         }
#       }
#     ]
#   })

#   # ─── Dependencies ────────────────────────────────────────────────
#   depends_on = [aws_ecr_repository.this]
# }


# data "aws_caller_identity" "current" {}
# # This resource attaches a policy to your ECR repository to allow
# # the Lambda service to pull images for the specified function.
# resource "aws_ecr_repository_policy" "this" {
#   for_each = var.ecr

#   repository = each.value.name

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = concat(
#       [
#         {
#           Sid      = "LambdaECRImageRetrievalPolicy",
#           Effect   = "Allow",
#           Principal = {
#             Service = "lambda.amazonaws.com"
#           },
#           Action = [
#             "ecr:BatchGetImage",
#             "ecr:GetDownloadUrlForLayer"
#           ],
#           Condition = {
#             StringEquals = {
#               "aws:SourceArn" = "arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:${each.value.lambda}"
#             }
#           }
#         }
#       ],
#       each.value.ecs != false ? [
#         {
#           Sid      = "ECSECRImageRetrievalPolicy",
#           Effect   = "Allow",
#           Principal = {
#             Service = "ecs-tasks.amazonaws.com"
#           },
#           Action = [
#             "ecr:BatchGetImage",
#             "ecr:GetDownloadUrlForLayer",
#             "ecr:GetAuthorizationToken"
#           ]
#         }
#       ] : []
#     )
#   })

#   depends_on = [aws_ecr_repository.this]
# }

