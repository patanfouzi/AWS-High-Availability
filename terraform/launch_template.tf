resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project}-lt-"
  image_id      = aws_ami_from_instance.from_instance.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  iam_instance_profile { name = aws_iam_instance_profile.ec2_profile.name }

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(file("${path.module}/scripts/user_data.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.project}-instance" }
  }
}
