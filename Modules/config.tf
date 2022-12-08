terraform {
  backend "s3" {
    bucket = "acs730-skoochakpour"       // Bucket where to SAVE Terraform State
    key    = "terraform/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                 // Region where bucket is created
  }
}