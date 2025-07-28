data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_instance" "ec2" {
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.vpc_aws_private_subnet_1.id
  vpc_security_group_ids  = [aws_security_group.sg_ec2a.id]
  key_name                = "mac"
  tags = {
    Name = "EC2A"
  }
}