resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  iam_instance_profile { name = aws_iam_instance_profile.ec2_profile.name }

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = filebase64("${path.module}/userdata.sh")

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.project}-instance" }
  }
}
