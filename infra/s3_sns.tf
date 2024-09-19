resource "aws_s3_bucket" "upload_bucket" {
  bucket = "meu-upload-bucket"
  acl    = "private"
}

resource "aws_s3_bucket_notification" "s3_notification" {
  bucket = aws_s3_bucket.upload_bucket.id

  topic {
    topic_arn = aws_sns_topic.file_upload_topic.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_sns_topic" "file_upload_topic" {
  name = "file-upload-topic"
}

resource "aws_sns_topic_subscription" "sns_email_subscription" {
  topic_arn = aws_sns_topic.file_upload_topic.arn
  protocol  = "email"
  endpoint  = "cintra.70@gmail.com" # Substitua pelo seu e-mail
}
