import boto3
import os
import io
from PIL import Image

# Initialize S3 client
s3 = boto3.client("s3")

# Resize dimensions
RESIZE_WIDTH = 200
RESIZE_HEIGHT = 200

def lambda_handler(event, context):
    try:
        # Extract bucket and object key from event
        source_bucket = event["Records"][0]["s3"]["bucket"]["name"]
        source_key = event["Records"][0]["s3"]["object"]["key"]
        
        # Destination bucket from environment variable
        destination_bucket = os.environ["DEST_BUCKET"]
        
        # Download the image from S3
        image_obj = s3.get_object(Bucket=source_bucket, Key=source_key)
        image_data = image_obj["Body"].read()
        
        # Open image with PIL
        image = Image.open(io.BytesIO(image_data))
        
        # Resize image
        image = image.resize((RESIZE_WIDTH, RESIZE_HEIGHT))
        
        # Convert image back to bytes
        image_buffer = io.BytesIO()
        image.save(image_buffer, format="JPEG")
        image_buffer.seek(0)
        
        # New file name
        destination_key = f"resized_{source_key}"
        
        # Upload resized image to destination bucket
        s3.put_object(
            Bucket=destination_bucket,
            Key=destination_key,
            Body=image_buffer,
            ContentType="image/jpeg"
        )
        
        print(f"Resized image {source_key} and saved to {destination_bucket} as {destination_key}")
        
        return {
            "statusCode": 200,
            "body": f"Image {source_key} resized and saved as {destination_key}"
        }
    
    except Exception as e:
        print(f"Error processing image: {str(e)}")
        return {
            "statusCode": 500,
            "body": "Error processing image"
        }
