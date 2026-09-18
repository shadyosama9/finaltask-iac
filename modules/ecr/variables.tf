variable "tags" {
  type = map(any)
}

variable "env" {
  type = string
}

variable "project" {
  description = "Project name prefix"
  type        = string
}

variable "ecr" {
  description = "Configuration map for Elastic Container Registry (ECR) repositories"
  type = map(object({

    name = string
    ecs  = optional(bool, false)
    # Whether image tags can be overwritten (MUTABLE) or prevent overwrites (IMMUTABLE)
    image_tag_mutability = optional(string, "MUTABLE")

    # Configuration for automated image scanning on push
    image_scanning_configuration = optional(object({
      # Whether to scan images for vulnerabilities when pushed to the repository
      scan_on_push = bool
    }), null)

    # Configuration for repository lifecycle policies
    # lifecycle_policy = optional(object({
    #   # Whether to enable lifecycle policy rules for this repository
    #   enabled = bool

    #   # Number of most recent images to retain when pruning tagged images
    #   retain_count = optional(number,10)
    # }), null)

    # lambda = optional(string, "*")

  }))

  default = {}
}