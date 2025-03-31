Use Case: Automated Image Resizing with AWS Lambda and S3
This project automates the process of resizing images whenever they are uploaded to an Amazon S3 bucket. The resized images are then stored in a separate destination bucket. This is achieved using AWS Lambda, which is triggered by an S3 event whenever a new image is uploaded.
Workflow Overview:
1.	User uploads an image to the source bucket: image-upload-source-56789.
2.	An S3 event notification triggers an AWS Lambda function.
3.	The Lambda function processes the image:
   o	Downloads it from image-upload-source-56789.
   o	Resizes the image using the Pillow library in Python.
   o	Saves the resized image to the destination bucket: image-upload-destination-56789.
4.	The resized image is now available in the destination bucket for further use.
Deployment Details:
   •	The Lambda function is written in Python and packaged as a ZIP file (lambda.zip).
   •	This ZIP file was manually uploaded to AWS Lambda via Terraform or AWS CLI.
   •	The Terraform script provisions:
      o	Two S3 buckets: image-upload-source-56789 (input) and image-upload-destination-56789 (output).
      o	An IAM role allowing Lambda to access S3.
      o	An S3 event notification to trigger Lambda when an image is uploaded.
This setup ensures a fully automated serverless image processing pipeline with AWS services. 
Below are the screenshots fo the relvant buckets.

1. Uploaded image

<img width="950" alt="image" src="https://github.com/user-attachments/assets/3a50420b-0b17-49c9-bd9a-3459c2df9cdb" />

2. Downloaded - Resized Image

<img width="949" alt="image" src="https://github.com/user-attachments/assets/e68e61a0-d3dd-49be-b4d6-5cf42754413d" />


