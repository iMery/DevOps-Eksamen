import base64
import boto3
import json
import random
import os
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3", region_name="eu-west-1")

# Environment variables
BUCKET_NAME = os.getenv("BUCKET_NAME")
KANDIDAT_NR = os.getenv("KANDIDAT_NR")

if not BUCKET_NAME or not KANDIDAT_NR:
    raise ValueError("Environment variables BUCKET_NAME and KANDIDAT_NR must be set.")

MODEL_ID = "amazon.titan-image-generator-v1"

def generate_image(prompt):
    logger.info("Generating image for prompt: %s", prompt)
    seed = random.randint(0, 2147483647)
    s3_image_path = f"{KANDIDAT_NR}/titan_{seed}.png"

    native_request = {
        "taskType": "TEXT_IMAGE",
        "textToImageParams": {"text": prompt},
        "imageGenerationConfig": {
            "numberOfImages": 1,
            "quality": "standard",
            "cfgScale": 8.0,
            "height": 512,
            "width": 512,
            "seed": seed,
        }
    }

    try:
        response = bedrock_client.invoke_model(
            modelId=MODEL_ID,
            body=json.dumps(native_request)
        )
        model_response = json.loads(response["body"].read())
    except Exception as e:
        logger.error("Error invoking Bedrock model: %s", str(e))
        raise RuntimeError(f"Failed to invoke Bedrock model: {str(e)}")

    if "images" not in model_response or not model_response["images"]:
        logger.error("No images returned by Bedrock model.")
        raise RuntimeError("No images returned by Bedrock model.")

    try:
        base64_image_data = model_response["images"][0]
        image_data = base64.b64decode(base64_image_data)
    except Exception as e:
        logger.error("Error decoding base64 image data: %s", str(e))
        raise RuntimeError(f"Failed to decode base64 image data: {str(e)}")

    try:
        s3_client.put_object(Bucket=BUCKET_NAME, Key=s3_image_path, Body=image_data)
        logger.info("Image uploaded to S3: %s", s3_image_path)
    except Exception as e:
        logger.error("Error uploading image to S3: %s", str(e))
        raise RuntimeError(f"Failed to upload image to S3: {str(e)}")

    return s3_image_path

def lambda_handler(event, context):
    logger.info("Received event: %s", event)
    body = json.loads(event.get('body', '{}'))
    prompt = body.get('prompt', '')

    if not prompt:
        logger.error("Prompt missing in request")
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Prompt is missing in the request."})
        }

    try:
        s3_image_path = generate_image(prompt)
    except Exception as e:
        logger.error("Error generating image: %s", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": f"Could not generate image: {str(e)}"})
        }

    image_url = f"s3://{BUCKET_NAME}/{s3_image_path}"
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Image generated and saved!",
            "image_url": image_url
        })
    }
print("Debugging deployment")