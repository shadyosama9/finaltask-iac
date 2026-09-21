terraform {
  source = "../../../modules/rds"
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

dependency "vpc" {
  config_path = "../vpc"
}

dependency "security_groups" {
  config_path = "../sg"
}

dependency "kms" {
  config_path = "../kms"
}

inputs = {
  env     = include.env.locals.env
  project = include.project.locals.project
  tags    = include.tags.locals.tags

  subnet_ids = dependency.vpc.outputs.private_subnet_ids # required (map(string))

  subnet_groups = { # required (map(object))
    postgres = {
      # ─── Subnet Group Configuration ───────────────────────────────────
      name        = "postgres-subnet-group"                   # required (string)
      description = "Subnet Group for Postgres RDS instances" # optional (string, default: null)
      subnet_keys = ["priv-sub-1", "priv-sub-2"]              # required (list(string))
    }
  }

  parameters = { # optional (map(object), default: {})
    postgres = {
      # ─── Parameter Group Configuration ───────────────────────────────
      name   = "postgres-params" # required (string)
      family = "postgres18"      # required (string)

      # ─── Parameters ───────────────────────────────────────────────────
      parameter = [
        { name = "log_connections", value = "all" },             # log every successful connection
        { name = "log_disconnections", value = "1" },            # log every disconnection
        { name = "log_min_duration_statement", value = "1000" }, # log queries slower than 1s
        { name = "log_statement", value = "ddl" },               # log all DDL statements
        # { name = "rds.force_ssl", value = "1" }                  # reject all non-SSL connections
      ]
    }
  }

  rds = { # optional (map(object), default: {})
    postgres = {
      # ─── Basic Configuration ──────────────────────────────────────────
      identifier                  = "postgres-db" # required (string)
      engine                      = "postgres"    # required (string)
      engine_version              = "18"          # required (string)
      instance_class              = "db.t3.micro" # required (string)
      db_name                     = "nix"         # optional (string, default: null)
      username                    = "nix_admin"   # required (string)
      manage_master_user_password = true          # optional (bool, default: true)
      parameter_group_key_name    = "postgres"    # optional (string, default: null) — matches key in `parameters` block above

      # ─── Storage Configuration ────────────────────────────────────────
      allocated_storage     = 20                                         # required (number)
      storage_encrypted     = true                                       # required (bool)
      kms_key_id            = dependency.kms.outputs.kms_key_arns["rds"] # optional (string, default: null)
      storage_type          = "gp2"                                      # optional (string, default: "gp2")
      max_allocated_storage = 0                                          # optional (number, default: 0)

      # ─── IAM Configuration ────────────────────────────────────────────
      iam_database_authentication_enabled = true # optional (bool, default: false)

      # ─── Network Configuration ────────────────────────────────────────
      vpc_security_group_ids   = [dependency.security_groups.outputs.security_group_ids["postgres"]] # optional (list(string), default: null)
      db_subnet_group_key_name = "postgres"                                                          # optional (string, default: null)

      # ─── High Availability ────────────────────────────────────────────
      multi_az = false # required (bool) — run a standby replica in a second AZ for automatic failover

      # ─── Backup & Maintenance ─────────────────────────────────────────
      backup_retention_period = 7     # required (string)
      skip_final_snapshot     = false # optional (bool, default: false)

      # ─── Protection ───────────────────────────────────────────────────
      deletion_protection = true # required (bool) — block accidental `terraform destroy` / console deletion

      # ─── Settings ─────────────────────────────────────────────────────
      apply_immediately               = true           # optional (bool, default: true)
      auto_minor_version_upgrade      = false          # optional (bool, default: true)
      allow_major_version_upgrade     = false          # optional (bool, default: false)
      copy_tags_to_snapshot           = true           # optional (bool, default: false)
      enabled_cloudwatch_logs_exports = ["postgresql"] # ships Postgres logs to CloudWatch (optional set(string), default: [])
      cloudwatch_logs_retention_days  = 7              # optional (number, default: 7)
      performance_insights_enabled    = true           # optional (bool, default: false)
    }
  }
}
