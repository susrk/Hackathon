provider "aws" {
  region = "us-east-1"
}

# Create the source S3 bucket (original images)
resource "aws_s3_bucket" "input_bucket" {
  bucket = "image-upload-bucket-56789"
}

# Create the destination S3 bucket (resized images)
resource "aws_s3_bucket" "output_bucket" {
  bucket = "image-resized-bucket-56789"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-s3-image-resize-role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": { "Service": "lambda.amazonaws.com" },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

# IAM Policy for Lambda to Access S3
resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "LambdaS3ImageResizePolicy"
  description = "Allows Lambda to read/write objects from S3"

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": ["s3:GetObject", "s3:PutObject"],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.input_bucket.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.output_bucket.bucket}/*"
        ]
      }
    ]
  }
  EOF
}

# Attach IAM policy to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

# Deploy Lambda Function
resource "aws_lambda_function" "image_processor" {
  function_name    = "resize_image_function"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.8"
  handler          = "lambda_function.lambda_handler"
  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      DEST_BUCKET = aws_s3_bucket.output_bucket.bucket
    }
  }
}

# Grant S3 permission to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Resize"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}

# Configure S3 bucket to trigger Lambda on object creation
resource "aws_s3_bucket_notification" "s3_lambda_trigger" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
