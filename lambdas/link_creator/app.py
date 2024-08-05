import boto3
import os
import uuid

from typing import List

BUCKET_NAME = os.environ["BUCKET_NAME"]
IMAGES_HOSTNAME = os.environ["HOSTNAME"]
DESTINATION_PREFIX = "img"

s3_client = boto3.client('s3')

HTML_TOP = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dogs!</title>
</head>
<body>
    <h1>Links</h1>
"""

HTML_BOTTOM = """
    </ul>
</body>
</html>
"""


def generate_index_html(html_body: str, new_links: List[str]) -> str:
    new_file = HTML_TOP
    
    for i in html_body.readlines():
        if i.startswith("<li>"):
            new_file += i
    
    for i in new_links:
        new_file += i

    new_file += HTML_BOTTOM

    return new_file


def update_index_file(links: List[str]):
    # download index file
    current_index = s3_client.get_object(Bucket=BUCKET_NAME, Key="index.html")["Body"].read()
    # TODO check if file exists by hash??
    new_file = generate_html_link(current_index, links)

    s3_client.put_object()

def generate_html_link(u: uuid.UUID):
    return f"<li><a href=\"https://{IMAGES_HOSTNAME}/img/{u}\" target=\"_blank\" {u}</a></li>"


def move_object(obj_key: str) -> uuid.UUID:
    u = str(uuid.uuid4())
    s3_client.copy_object(
        ACL="private",
        Bucket=BUCKET_NAME,
        CopySource=f"{BUCKET_NAME}/{obj_key}",
        Key=f"{DESTINATION_PREFIX}/{u}"
    )

    return u

def handler(event, context):
    new_uuids = []
    new_links = []

    for record in event['Records']:
        try:
            k = record['s3']['object']['key']
            moved_object_uuid = move_object(k)
            new_uuids.append(moved_object_uuid)
        except Exception as e:
            print(f"error moving object - {e}")
    
    for u in new_uuids:
        new_links.append(generate_html_link(u))

    

