#!/bin/bash

SHA1=$1
echo -n "Sha in deploy script is"
echo $SHA1

# Deploy image to Docker Hub
docker push soutech/champaign_web:$SHA1

# Update Elastic Beanstalk
EB_BUCKET=champaign.dockerrun.files
echo 'Shipping source bundle to S3...'
zip -r9 $SHA1-config.zip Dockerrun.aws.json ./.ebextensions/
SOURCE_BUNDLE=$SHA1-config.zip

aws configure set default.region $AWS_REGION
aws s3 cp $SOURCE_BUNDLE s3://$EB_BUCKET/$SOURCE_BUNDLE

echo 'Creating new application version...'
aws elasticbeanstalk create-application-version --application-name 'Champaign core application' \
  --version-label $SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$SOURCE_BUNDLE
echo 'Updating environment...'
aws elasticbeanstalk update-environment --environment-name 'champaign' \
    --version-label $SHA1
