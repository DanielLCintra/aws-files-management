resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "meu-frontend-bucket-daniel-19092024"
}

resource "aws_s3_bucket_ownership_controls" "frontend_bucket" {
  bucket = aws_s3_bucket.frontend_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_bucket" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "frontend_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.frontend_bucket,
    aws_s3_bucket_public_access_block.frontend_bucket,
  ]

  bucket = aws_s3_bucket.frontend_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "frontend_bucket_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.frontend_bucket.bucket}/*"
      }
    ]
  })
}
