resource "aws_ami_from_instance" "from_instance" {
  name               = "$(project_id)-ami-${formatdate("YYYY-MM-DD-HH-MM-SS", timestamp())}"
  source_instance_id = var.source_instance_id
  snapshot_without_reboot = true

  tags = {
    Name = "myapp-prod-ami"
  }
}
