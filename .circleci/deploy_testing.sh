#!/bin/bash
set -eu -o pipefail

SHA1=$1
AWS_APPLICATION_NAME=$2
export AWS_ENVIRONMENT_NAME=$3
STATIC_BUCKET=$4

echo 'Deleting configuration files that do not apply to feature deployment'
rm .ebextensions/03_papertrail.config
rm .ebextensions/04_newrelic.config
rm .ebextensions/05_nginx_proxy.config

echo 'Shipping source bundle to S3...'
zip -r9 $SHA1-config.zip Dockerrun.aws.json ./.ebextensions/
SOURCE_BUNDLE=$SHA1-config.zip

echo 'Shipping static assets to S3...'
id=$(docker create soutech/champaign_web:$SHA1)
docker cp $id:/champaign/public/assets statics

aws s3 sync statics/ s3://$STATIC_BUCKET/assets/

aws configure set default.region $AWS_REGION
aws s3 cp $SOURCE_BUNDLE s3://$EB_BUCKET/$SOURCE_BUNDLE

echo 'Creating new application version...'
aws elasticbeanstalk create-application-version --application-name "$AWS_APPLICATION_NAME" \
  --version-label $SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$SOURCE_BUNDLE
echo 'Updating environment...'
aws elasticbeanstalk update-environment --environment-name $AWS_ENVIRONMENT_NAME \
    --version-label $SHA1
