resource "aws_s3_bucket" "upload_bucket" {
  bucket = "meu-upload-bucket-daniel-19092024" # Troque pelo seu nome, porque o nome do bucket precisa ser único!

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

resource "aws_s3_bucket_public_access_block" "upload_bucket" {
  bucket = aws_s3_bucket.upload_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "upload_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.upload_bucket,
    aws_s3_bucket_public_access_block.upload_bucket,
  ]

  bucket = aws_s3_bucket.upload_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "upload_bucket_policy" {
  bucket = aws_s3_bucket.upload_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
     {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.upload_bucket.bucket}/*"
      }
    ]
  })
}
