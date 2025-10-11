resource "aws_launch_template" "app_lt" {                                                                    
  update_default_version = true
  image_id      = aws_ami_from_instance.from_instance.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name= var.key_name
  user_data = base64encode(file("${path.module}/scripts/user_data.sh"))
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project}-instance"
    }
  }
}
