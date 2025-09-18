 resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project}-lt-"
  image_id      = aws_ami_from_instance.from_instance.id
  instance_type = "t2.micro"
  key_name      = var.key_name

  # Multi-line user_data script (no extra quotes, no $() unless needed)
  user_data = <<-EOF
    #!/bin/bash
    set -e
    export DEBIAN_FRONTEND=noninteractive

    apt-get update -y
    apt-get upgrade -y

    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx

    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /tmp/amazon-cloudwatch-agent.deb
    dpkg -i /tmp/amazon-cloudwatch-agent.deb || true
    apt-get -f install -y || true

    cat <<'JSON' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
    {
      "agent": {
        "metrics_collection_interval": 60,
        "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
      },
      "metrics": {
        "metrics_collected": {
          "cpu": {
            "measurement": [
              {"name": "cpu_usage_idle", "rename": "CPU_IDLE", "unit": "Percent"},
              {"name": "cpu_usage_system", "rename": "CPU_SYS", "unit": "Percent"},
              {"name": "cpu_usage_user", "rename": "CPU_USER", "unit": "Percent"}
            ],
            "metrics_collection_interval": 60,
            "totalcpu": true
          },
          "mem": {
            "measurement": [
              {"name": "mem_used_percent", "unit": "Percent"}
            ],
            "metrics_collection_interval": 60
          },
          "disk": {
            "measurement": [
              {"name": "used_percent", "unit": "Percent"}
            ],
            "metrics_collection_interval": 60,
            "resources": ["*"]
          }
        }
      }
    }
    JSON

    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s || true
  EOF

  vpc_security_group_ids = [aws_security_group.app_sg.id]

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
