terraform {
  backend "s3" {
    bucket       = "testbkt17062025"
    key          = "sample_rds/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
  }
}