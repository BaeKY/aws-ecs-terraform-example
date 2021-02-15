#!/bin/bash

bucket=<YOUR_BUCKET_NAME>
region=<AWS_REGION>

aws s3api create-bucket --bucket $bucket_name --acl private --create-bucket-configuration LocationConstraint=$region