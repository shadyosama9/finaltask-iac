terraform {
  source = "../../../modules/load-balancer"
}

include "root" {
  path = "${get_parent_terragrunt_dir()}/../root.hcl"
}
include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    public_subnet_ids = {
      pub_sub_1 = "subnet-mock1"
      pub_sub_2 = "subnet-mock2"
    }
    vpc_ids = {
      main = "vpc-mock"
    }
  }
}
dependency "sg" {
  config_path = "../sg"
  mock_outputs = {
    security_group_ids = {
      load_balancer = "sg-mock"
    }
  }
}
dependency "acm" {
  config_path = "../acm"
  mock_outputs = {
    cert_arn = {
      cert = "arn:aws:acm:us-east-1:123456789012:certificate/mock-cert"
    }
  }
}

inputs = {
  tags = include.env.locals.tags

  load_balancers = {
    alb = {
      name                       = "shady-osama-backend-alb"
      internal                   = false
      load_balancer_type         = "application"
      enable_deletion_protection = false
      security_groups            = [dependency.sg.outputs.security_group_ids["load_balancer"]]
      subnets                    = [
        dependency.vpc.outputs.public_subnet_ids["pub_sub_1"],
        dependency.vpc.outputs.public_subnet_ids["pub_sub_2"]
      ]
      tags = {
        Name = "shady-osama-backend-alb"
      }
    }
  }

  target_groups = {
    tg = {
      name        = "shady-osama-backend-tg"
      port        = 5000
      protocol    = "HTTP"
      target_type = "ip"
      vpc_id      = dependency.vpc.outputs.vpc_ids["main"]
      health_check = {
        path                = "/health"
        protocol            = "HTTP"
        matcher             = "200-299"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 3
      }
    }
  }

  listeners = {
    http-listener = {
      load_balancer_key = "alb"
      port              = 80
      protocol          = "HTTP"
      default_action = {
        type = "redirect"
        redirect = {
          protocol    = "HTTPS"
          port        = "443"
          status_code = "HTTP_301"
        }
      }
      tags = {
        Name = "shady-osama--http-listener"
      }
    }
    https-listener = {
      load_balancer_key = "alb"
      port              = 443
      protocol          = "HTTPS"
      ssl_policy        = "ELBSecurityPolicy-2016-08"
      certificate_arn   = dependency.acm.outputs.cert_arn["cert"]
      default_action = {
        type = "fixed-response"
        fixed_response = {
          content_type = "text/plain"
          message_body = "Bad request"
          status_code  = "400"
        }
      }
      tags = {
        Name = "shady-osama-https-listener"
      }
    }
  }

  listener_rules = {
    domain = {
      listener_key     = "https-listener"
      priority         = 100
      target_group_key = "tg"
      host_headers     = ["shadyosama.vertexlab.net", "*.shadyosama.vertexlab.net"]
    }
  }
}
