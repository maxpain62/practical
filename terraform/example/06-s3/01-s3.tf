resource "aws_s3_bucket" "eos_s3_bubket" {
  bucket = "eos-s3-bubket"
  tags = {
    Name = "eos-s3-bubket"
    env = "dev"
  }
}