data "aws_ssm_parameter" "vpc_id" {     # Retrieve the VPC ID from SSM Parameter Store
  name = "/${var.project_name}/${var.environment}/vpc_id"
}