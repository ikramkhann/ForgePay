#!/usr/bin/env bash
# AI Attribution Block: LocalStack initialization script creating S3 backend bucket and KMS keys.
set -euo pipefail

echo "Initializing LocalStack AWS resources for ForgePay..."

awslocal s3 mb s3://forgepay-terraform-state --region ap-south-1
awslocal dynamodb create-table \
  --table-name forgepay-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
  --region ap-south-1

awslocal kms create-key --description "ForgePay local KMS CMK" --region ap-south-1

echo "LocalStack resources initialized successfully."
