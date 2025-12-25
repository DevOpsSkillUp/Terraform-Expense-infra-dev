module "db" {
  source = "terraform-aws-modules/rds/aws"
  identifier = local.resource_name #expense-dev

  engine            = "mysql"
  engine_version    = "8.0.40"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20

  db_name  = "transactions" # AWS will create this schema automatically
  username = "root"
  port     = "3306"
  password = "ExpenseApp1"
  manage_master_user_password = false # Normall we would use SSM or Secrets Manager to manage this password but for simplicity we are hardcoding it here.

  vpc_security_group_ids = [local.mysql_sg_id]  # list of SG IDs

  # DB subnet group
  create_db_subnet_group = false  # we are using an existing subnet group stored in SSM
  db_subnet_group_name = local.database_subnet_group_name

  # DB parameter group
  family = "mysql8.0" 

  # DB option group
  major_engine_version = "8.0"

  # Database Deletion Protection
  deletion_protection = false   # if true, we cannot delete the RDS instance via Terraform. In real-time, this should be true to prevent accidental deletion.
  skip_final_snapshot = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]

  tags = merge(
    var.common_tags,
    {
        Name = local.resource_name
    }
  )
}

# Create a Route53 CNAME record for the RDS instance endpoint address 
resource "aws_route53_record" "www-dev" {
  zone_id = var.zone_id
  name    = "mysql-${var.environment}.${var.domain_name}"
  type    = "CNAME"
  ttl     = 5
  records = [module.db.db_instance_address]  # check the output variable name in the module
}
