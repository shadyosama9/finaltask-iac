terraform {
  source = "../../../modules/amplify"
}

include "root" {
  path = "${get_parent_terragrunt_dir()}/../root.hcl"
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

include "project" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

include "tags" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}


inputs = {
  env     = include.env.locals.env
  project = include.project.locals.project
  tags    = include.tags.locals.tags

  amplify_apps = { # optional (map(object), default: {})
    front = {
      # ─── Basic Configuration ──────────────────────────────────────────
      name       = "shady-osama-final-task-frontend"                                                      # required (string)
      repository = "https://github.com/shadyosama9/vue3-realworld-example-app.git" # required (string)


      # ─── Branch Management ────────────────────────────────────────────
      enable_auto_branch_creation = false # optional (bool, default: true) — deploy only branches configured below
      enable_branch_auto_deletion = true  # optional (bool, default: true)
      auto_branch_creation_config = null  # optional (object, default: null)

      # ─── Access & Environment ─────────────────────────────────────────
      environment_variables = {}   # optional (map(string), default: {})
      secret_arn            = null # optional (string, default: null)

      # Template addition: SPA rewrite so client-side routes (e.g. React Router) resolve
      # to index.html instead of 404ing, while leaving real static assets untouched
      # custom_rule = [ # optional (list(object), default: [])
      #   {
      #     source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|jpeg|js|png|txt|svg|woff|woff2|ttf|map|json)$)([^.]+$)/>"
      #     status = "200"
      #     target = "/index.html"
      #   }
      # ]
    }
  }

  amplify_branches = { # optional (map(object), default: {})
    main = {
      # ─── Basic Configuration ──────────────────────────────────────────
      name        = "front"      # required (string)
      branch_name = "main"       # required (string)
      stage       = "PRODUCTION" # optional (string, default: null)
      framework   = "VUE"        # optional (string, default: null)

      # ─── Build Settings ───────────────────────────────────────────────
      environment_variables = {
        BASE_URL      = "/"
        VITE_API_HOST = "https://api.shadyosama.vertexlab.net"
      }                           # optional (map(string), default: {})
      enable_notification = false # optional (bool, default: false)
      enable_auto_build   = true  # optional (bool, default: true)
    }
  }

  amplify_domains = { # optional (map(object), default: {})
    front = {
      # ─── Domain Configuration ─────────────────────────────────────────
      app_name    = "front"                    # required (string)
      domain_name = "shadyosama.vertexlab.net" # required (string)
      subdomains = [
        {
          branch_name      = "main"
          subdomain_prefix = "app"
        }
      ]

      # ─── Certificate Configuration ────────────────────────────────────
      certificate_type       = "AMPLIFY_MANAGED" # optional (string, default: "AMPLIFY_MANAGED")
      custom_certificate_arn = null              # optional (string, default: null)
      wait_for_verification  = false             # optional (bool, default: false)
    }
  }
}
