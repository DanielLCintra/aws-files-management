resource "aws_sns_topic" "s3-event-notification-topic" {
  name   = "s3-event-notification-topic"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
    "Effect": "Allow",
    "Principal": { "Service": "s3.amazonaws.com" },
    "Action": "SNS:Publish",
    "Resource": "arn:aws:sns:us-east-1:897749373053:s3-event-notification-topic",
    "Condition":{
        "StringEquals":{"aws:SourceAccount":"897749373053"},
        "ArnLike":{"aws:SourceArn":"${aws_s3_bucket.upload_bucket.arn}"}

    }
  }]
}
POLICY
}

resource "aws_sns_topic_subscription" "topic-email-subscription" {
  topic_arn = aws_sns_topic.s3-event-notification-topic.arn
  protocol  = "email"
  endpoint  = "cintra.70@gmail.com" # Substitua pelo seu e-mail
}

resource "aws_s3_bucket_notification" "bucket-notification" {
  bucket = aws_s3_bucket.upload_bucket.id

  topic {
    topic_arn = aws_sns_topic.s3-event-notification-topic.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
