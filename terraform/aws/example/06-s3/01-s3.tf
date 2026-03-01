resource "aws_s3_bucket" "eos_s3_bubket" {
  bucket = "eos-s3-bubket"
  tags = {
    Name = "eos-s3-bubket"
    env = "dev"
  }
}

resource "aws_s3_bucket_public_access_block" "eos_s3_bubket_public_access" {
  bucket = aws_s3_bucket.eos_s3_bubket.id
  block_public_acls   = false
  block_public_policy = false
}