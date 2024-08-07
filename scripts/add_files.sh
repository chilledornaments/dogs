#!/usr/bin/env bash

set -e

BUCKET=$(aws s3 ls | grep dog-api | cut -f 3 -d ' ')
PREFIX="upload/"

aws s3 cp --recursive ./img/ "s3://${BUCKET}/${PREFIX}"