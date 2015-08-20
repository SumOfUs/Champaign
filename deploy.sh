#!/bin/bash

SHA1=$1

# Deploy image to Docker Hub
docker push soutech/champaign_web:$SHA1

# Create new Elastic Beanstalk version

EB_BUCKET=champaign.dockerrun.files
DOCKERRUN_FILE=$SHA1-Dockerrun.aws.json
sed "s/<TAG>/$SHA1/" < Dockerrun.aws.json.template > $DOCKERRUN_FILE

aws configure set default.region $AWS_REGION
aws s3 cp $DOCKERRUN_FILE s3://$EB_BUCKET/$DOCKERRUN_FILE
aws elasticbeanstalk create-application-version --application-name 'Champaign core application' \
  --version-label $SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$DOCKERRUN_FILE

# Update Elastic Beanstalk environment to new version
aws elasticbeanstalk update-environment --environment-name 'champaign' \
    --version-label $SHA1
