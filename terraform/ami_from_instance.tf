resource "aws_ami_from_instance" "from_instance" {
  name               = "${var.project}-ami-${timestamp()}"
  source_instance_id = var.source_instance_id
  description        = "AMI created from ${var.source_instance_id}"
  snapshot_without_reboot = true   # non-disruptive snapshot; set false if you want clean state with restart
  tags = { Name = "${var.project}-ami" }
}
