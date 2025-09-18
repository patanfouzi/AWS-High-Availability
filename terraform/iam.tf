data "aws_iam_policy" "cw_agent_policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_iam_policy" "ssm_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"] 
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.project}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags = { 
    Name = "${var.project}-ec2-role" 
  }
}

resource "aws_iam_role_policy_attachment" "attach_cw" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = data.aws_iam_policy.cw_agent_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = data.aws_iam_policy.ssm_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project}-instance-profile"
  role = aws_iam_role.ec2_role.name
}
