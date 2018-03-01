#!/bin/bash
set -eu -o pipefail

SOURCE_BUNDLE=$CIRCLE_SHA1-config.zip

echo 'Deleting configuration files that do not apply to feature deployment'
rm .ebextensions/04_newrelic.config
rm .ebextensions/05_nginx_proxy.config

echo 'Shipping source bundle to S3...'
cat Dockerrun.aws.json.template | envsubst > Dockerrun.aws.json
zip -r9 $CIRCLE_SHA1-config.zip Dockerrun.aws.json ./.ebextensions/
aws configure set default.region $AWS_REGION
aws s3 cp $SOURCE_BUNDLE s3://$EB_BUCKET/$SOURCE_BUNDLE

echo 'Shipping static assets to S3...'
aws s3 sync public/assets s3://$S3_BUCKET/assets/
aws s3 sync public/packs/ s3://$S3_BUCKET/packs/

echo 'Creating new application version...'
aws elasticbeanstalk create-application-version --application-name "$AWS_APPLICATION_NAME" \
  --version-label $CIRCLE_SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$SOURCE_BUNDLE

echo 'Updating environment...'
aws elasticbeanstalk update-environment --environment-name $AWS_ENVIRONMENT_NAME \
    --version-label $CIRCLE_SHA1
