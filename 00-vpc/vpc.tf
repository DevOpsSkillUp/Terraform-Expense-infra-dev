module "vpc" {
    source = "git::https://github.com/DevOpsSkillUp/Terraform.git//modules/custom_templates/aws_vpc?ref=main"
    project_name = var.project_name
    environment = var.environment
    vpc_cidr = var.vpc_cidr
    common_tags = var.common_tags
    vpc_tags = var.vpc_tags
    public_subnet_cidrs = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    database_subnet_cidrs = var.database_subnet_cidrs
    is_peering_required = true
}

# this can be included in module, ask team lead to add it in the module or use it as a separate resource as below
resource "aws_db_subnet_group" "expense" { 
  name       = "${var.project_name}-${var.environment}"
  subnet_ids = module.vpc.database_subnet_ids  # DB subnet group --> group of DB subnets

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}"
    }
  )
}