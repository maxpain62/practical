resource "aws_s3_bucket" "eos_s3_bubket" {
  bucket = "eos_s3_bubket"
  tags = {
    Name = "eos_s3_bubket"
    env = "dev"
  }
}