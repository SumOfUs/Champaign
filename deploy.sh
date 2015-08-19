#!/bin/bash

SHA1=$1

# Deploy image to Docker Hub
docker push soutech/champaign_web:$SHA1

# Create new Elastic Beanstalk version
aws elasticbeanstalk create-application-version --application-name 'Champaign core application' \
  --version-label $SHA1

# Update Elastic Beanstalk environment to new version
aws elasticbeanstalk update-environment --environment-name 'champaign' \
    --version-label $SHA1
