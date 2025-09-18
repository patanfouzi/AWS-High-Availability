 resource "aws_launch_template" "app_lt" {
  name   = "${var.project}-lt"
  image_id      = aws_ami_from_instance.from_instance.id
  instance_type = "t2.micro"
  key_name      = var.key_name  
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
# Log output
exec > /var/log/user-data.log 2>&1
set -x
# Download and run the script from S3
aws s3 cp s3://cloudwatch-script-bkt/userdata.sh /tmp/userdata.sh
chmod +x /tmp/userdata.sh
bash /tmp/userdata.sh
EOF
)


  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_profile.arn
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project}-instance"
    }
  }
}
