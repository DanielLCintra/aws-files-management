resource "aws_s3_bucket" "upload_bucket" {
  bucket = "meu-upload-bucket-daniel-19092024" #troque pelo seu nome, pq o nome a bucket precisa ser único!

  tags = {
    Name = "upload_bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "upload_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.upload_bucket]

  bucket = aws_s3_bucket.upload_bucket.id
  acl    = "private"
}
