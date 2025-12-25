module "alb" {
  source = "terraform-aws-modules/alb/aws"   # Use the official AWS module for ALB
  internal = true # default is false, set to true for internal ALB
  
  # expense-dev-app-alb
  name    = "${var.project_name}-${var.environment}-app-alb"
  vpc_id  = data.aws_ssm_parameter.vpc_id.value
  subnets = local.private_subnet_ids
  create_security_group = false # Use this for custom security group
  security_groups = [local.app_alb_sg_id]
  enable_deletion_protection = false #default is false (in AWS). When false, deletion protection is disabled, so the LB can be deleted via Console/API. Set to true to prevent accidental deletion.
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-app-alb"
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.alb.arn 
  port              = "80"
  protocol          = "HTTP"

  # default action for HTTP listener to return a fixed response
  default_action { 
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from backend APP ALB</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "app_alb" {
  zone_id = var.zone_id
  name    = "*.app-dev.${var.domain_name}" # Use wildcard for subdomain routing like *app-dev.example.com or  xyzapp-dev.example.com
  type    = "A"

  # these are ALB DNS name and zone information
  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = false
  }
}