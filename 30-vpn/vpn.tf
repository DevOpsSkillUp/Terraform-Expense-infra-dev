resource "aws_key_pair" "openvpnas" {
  key_name   = "openvpnas"
  #  file function is used to read the public key file from the local machine
  public_key = file("C:\\devops\\daws-82s\\openvpnas.pub") # create a public key file and provide its path here in local machine using ssh-keygen command
}
# openvpn access server aws ec2 in website for automation (https://openvpn.net/as-docs/v3/aws-byol.html#additional-security-steps-you-can-take-after-installation-260600)
resource "aws_instance" "openvpn" {
  ami                    = data.aws_ami.openvpn.id
  key_name = aws_key_pair.openvpnas.key_name # Argument Reference from aws_key_pair resource
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
  instance_type          = "t3.micro"
  subnet_id   = local.public_subnet_id # vpn will be installed on public subnet for internet access
  user_data = file("user-data.sh") # VPN Connection details will be provided in this script, EC2 and bastion will be in one place
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-vpn"
    }
  )
}

output "vpn_ip" {
  value       = aws_instance.openvpn.public_ip
}
