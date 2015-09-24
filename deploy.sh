#!/bin/bash
set -eu -o pipefail

SHA1=$1
AWS_APPLICATION_NAME=$2
AWS_ENVIRONMENT_NAME=$3

# Update Elastic Beanstalk
echo 'Shipping source bundle to S3...'
zip -r9 $SHA1-config.zip Dockerrun.aws.json ./.ebextensions/
SOURCE_BUNDLE=$SHA1-config.zip

aws configure set default.region $AWS_REGION
aws s3 cp $SOURCE_BUNDLE s3://$EB_BUCKET/$SOURCE_BUNDLE

echo 'Creating new application version...'
aws elasticbeanstalk create-application-version --application-name "$AWS_APPLICATION_NAME" \
  --version-label $SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$SOURCE_BUNDLE
echo 'Updating environment...'
aws elasticbeanstalk update-environment --environment-name $AWS_ENVIRONMENT_NAME \
    --version-label $SHA1
