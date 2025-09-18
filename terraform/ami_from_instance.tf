resource "aws_ami_from_instance" "from_instance" {
  name               = "myapp-prod-ami-${formatdate("YYYY-MM-DD-HH-MM-SS", timestamp())}"
  source_instance_id = "i-08e862327bb75aa71"
  snapshot_without_reboot = true

  tags = {
    Name = "myapp-prod-ami"
  }
}
