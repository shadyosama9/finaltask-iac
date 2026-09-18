terraform {
  source = "../../../modules/vpc"
}

include "root" {
  path = "${get_parent_terragrunt_dir()}/../root.hcl"
}
include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

inputs = {
  env        = include.env.locals.env
  project    = include.env.locals.project
  tags       = include.env.locals.tags

  vpc = {
    main = {
      create_igw          = true
      cidr_block           = "10.0.0.0/16"
      enable_dns_hostnames = true
      enable_dns_support   = true
    }
  }

  eip = {
    nat_eip = {
      create = true
      domain = "vpc"
    }
  }

  nat = {
    nat_gw_1 = {
      subnet_key = "pub_sub_1"
      eip_key    = "nat_eip"
    }
  }

  subnets = {
    pub_sub_1 = {
      vpc_key                 = "main"
      create_nacl             = false
      availability_zone       = "us-east-1a"
      cidr_block              = "10.0.1.0/24"
      map_public_ip_on_launch = true
    }
    pub_sub_2 = {
      vpc_key                 = "main"
      create_nacl             = false
      availability_zone       = "us-east-1b"
      cidr_block              = "10.0.2.0/24"
      map_public_ip_on_launch = true
    }
    priv_sub_1 = {
      vpc_key                 = "main"
      create_nacl             = false
      availability_zone       = "us-east-1a"
      cidr_block              = "10.0.32.0/19"
      map_public_ip_on_launch = false
    }
    priv_sub_2 = {
      vpc_key                 = "main"
      create_nacl             = false
      availability_zone       = "us-east-1b"
      cidr_block              = "10.0.64.0/19"
      map_public_ip_on_launch = false
    }
  }

  route_tables = {
    pub_rt_1 = {
      vpc_key     = "main"
      subnet_keys = ["pub_sub_1", "pub_sub_2"]
      use_igw     = true
      routes      = [{ cidr_block = "0.0.0.0/0" }]
    }
    priv_rt_1 = {
      vpc_key     = "main"
      subnet_keys = ["priv_sub_1", "priv_sub_2"]
      use_nat     = true
      routes      = [{ cidr_block = "0.0.0.0/0", nat_key = "nat_gw_1" }]
    }
  }
}
