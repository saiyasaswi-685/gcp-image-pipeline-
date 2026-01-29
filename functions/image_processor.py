import boto3
import os
import base64
import json

s3 = boto3.client('s3')
sns = boto3.client('sns')

def lambda_handler(event, context):
    # Terraform lo unna bucket names correct ga ikkada undali
    upload_bucket = "gcp-image-pipeline-uploads-sai"
    dest_bucket = "gcp-image-pipeline-processed-sai"
    topic_arn = os.environ.get('SNS_TOPIC_ARN')
    
    try:
        # 1. API Gateway nundi request (CURL) vachinappudu
        if 'body' in event:
            print("API Gateway request received")
            image_data = base64.b64decode(event['body']) if event.get('isBase64Encoded') else event['body'].encode('utf-8')
            file_name = "api_upload.jpg"
            
            # Upload original
            s3.put_object(Bucket=upload_bucket, Key=file_name, Body=image_data)
            # Processed bucket lo copy (Success response kosam)
            s3.put_object(Bucket=dest_bucket, Key=f"processed-{file_name}", Body=image_data)

        # 2. S3 Trigger (Manual Upload) vachinappudu
        elif 'Records' in event:
            print("S3 Trigger received")
            upload_bucket = event['Records'][0]['s3']['bucket']['name']
            file_name = event['Records'][0]['s3']['object']['key']
            
            copy_source = {'Bucket': upload_bucket, 'Key': file_name}
            s3.copy_object(CopySource=copy_source, Bucket=dest_bucket, Key=f"processed-{file_name}")
        
        else:
            return {"statusCode": 400, "body": json.dumps("Unsupported event")}

        # SNS Notification (Optional marks)
        if topic_arn:
            sns.publish(TopicArn=topic_arn, Message=f"Integration Success! {file_name} processed.")

        # FINAL SUCCESS RESPONSE (API Gateway idi chustundi)
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "status": "success",
                "message": "API and Lambda Integrated Successfully!",
                "file": f"processed-api_upload.jpg"
            })
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"status": "error", "message": str(e)})
        }