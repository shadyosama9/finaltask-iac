output "load_balancer_arns" {
  value = {
    for name, load_balancer in aws_lb.this :
    name => load_balancer.arn
  }
}

output "load_balancer_dns_names" {
  value = {
    for name, load_balancer in aws_lb.this :
    name => load_balancer.dns_name
  }
}

output "load_balancer_arn_suffixes" {
  description = "Load balancer ARN suffixes for CloudWatch dimensions"
  value = { for key, load_balancer in aws_lb.this : key => load_balancer.arn_suffix }
}

output "target_group_arns" {
  value = {
    for name, target_group in aws_lb_target_group.this :
    name => target_group.arn
  }
}
