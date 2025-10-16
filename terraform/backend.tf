terraform {
  backend "s3" {
    bucket         = "my-tf-state-file-backend"    # replace
    key            = "autoscaling/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
