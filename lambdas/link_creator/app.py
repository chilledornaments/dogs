import boto3
from typing import List

DESTINATION_PREFIX = "img"
IMAGE_INDEX_S3_KEY_NAME = "image_map.txt"

s3_client = boto3.client('s3')


def get_current_records(bucket: str) -> List[str]:
    o = s3_client.get_object(
        Bucket=bucket,
        Key=IMAGE_INDEX_S3_KEY_NAME
    )

    object_contents = o["Body"].read().decode('utf-8')

    file_hashes = []

    for i in object_contents.split("|"):
        if i != "":
            file_hashes.append(i)

    return file_hashes


def add_new_records(bucket: str, current_records: List[str], new_records: List[str]):
    body = ""

    for c in current_records:
        body += c + "|"

    for new_record in new_records:
        # is it worth checking?
        if new_record not in current_records:
            body += new_record + "|"

    s3_client.put_object(
        Bucket=bucket,
        ACL="private",
        # cut the last character, which will be "|"
        Body=body[0:-1].encode(),
        Key=IMAGE_INDEX_S3_KEY_NAME
    )

    print("updated map object")


def move_object(bucket: str, obj_key: str, etag: str):
    s3_client.copy_object(
        ACL="private",
        Bucket=bucket,
        CopySource=f"{bucket}/{obj_key}",
        Key=f"{DESTINATION_PREFIX}/{etag}"
    )

    print("moved object")


def handler(event, context):
    new_etags = []
    # We'll only receive notifications from one bucket, so we only need to look at the first object to determine the bucket name
    bucket = event['Records'][0]['s3']['bucket']['name']

    for record in event['Records']:
        try:
            # etag is a "hash of the object. The ETag reflects changes only to the contents of an object, not its metadata"
            # meaning its a reliable-enough hash for use in identifying an image
            # https://docs.aws.amazon.com/AmazonS3/latest/API/API_Object.html
            etag = record['s3']['object']['eTag']
            k = record['s3']['object']['key']
            move_object(bucket, k, etag)
            new_etags.append(etag)
        except:
            print("failed to copy object")
            raise

    try:
        current_records = get_current_records(bucket)
    except:
        print("failed to get current records")

    try:
        add_new_records(bucket, current_records, new_etags)
    except:
        print("failed to add new records")

    print(f"added {len(new_etags)} new images")
