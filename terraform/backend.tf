terraform {
  backend "s3" {
    bucket         = "my-terraform-bkt-prod"    # replace
    key            = "autoscaling/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
