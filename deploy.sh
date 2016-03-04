#!/bin/bash
set -eu -o pipefail

SHA1=$1
AWS_APPLICATION_NAME=$2
export AWS_ENVIRONMENT_NAME=$3
STATIC_BUCKET=$4
export ENV_URL=$5

echo 'Setting up configuration for Papertrail logging'
export PAPERTRAIL_HOST=$(cut -d ":" -f 1 <<< $5)
export PAPERTRAIL_PORT=$(cut -d ":" -f 2 <<< $5)
export PAPERTRAIL_SYSTEM=$3
cat .ebextensions/03_papertrail.config | envsubst '$PAPERTRAIL_HOST:$PAPERTRAIL_PORT:$PAPERTRAIL_SYSTEM' >temp
mv temp .ebextensions/03_papertrail.config

echo 'Applying environment-specific configuration in .ebextensions'
envsubst '$AWS_ENVIRONMENT_NAME' <.ebextensions/04_newrelic.config >temp
mv temp .ebextensions/04_newrelic.config
envsubst '$ENV_URL' <.ebextensions/05_nginx_proxy.config >temp
mv temp .ebextensions/05_nginx_proxy.config

echo 'Shipping source bundle to S3...'
zip -r9 $SHA1-config.zip Dockerrun.aws.json ./.ebextensions/
SOURCE_BUNDLE=$SHA1-config.zip

echo 'Shipping static assets to S3...'
id=$(docker create soutech/champaign_web:$SHA1)
docker cp $id:/myapp/public/assets statics

aws s3 sync statics/ s3://$STATIC_BUCKET/assets/

aws configure set default.region $AWS_REGION
aws s3 cp $SOURCE_BUNDLE s3://$EB_BUCKET/$SOURCE_BUNDLE

echo 'Creating new application version...'
aws elasticbeanstalk create-application-version --application-name "$AWS_APPLICATION_NAME" \
  --version-label $SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$SOURCE_BUNDLE
echo 'Updating environment...'
aws elasticbeanstalk update-environment --environment-name $AWS_ENVIRONMENT_NAME \
    --version-label $SHA1

function check_application_status() {
  echo $(aws elasticbeanstalk describe-environments --environment-names $1  2>/dev/null \
    | jq -r '.Environments[].Status')
}

STATUS="$(stack_status $AWS_ENVIRONMENT_NAME)"

echo -n "."
while [[ "$STATUS" != "Ready" ]]
do
  sleep 15s
  STATUS="$(stack_status $AWS_ENVIRONMENT_NAME)"
  if [ "$STATUS" = "Degraded" ]; then
      echo ""
      echo "Your application appears to have deployed, but its status is currently degraded. Have a look at what's up."
      exit 1
  fi
  echo -n "."
done

echo "Triggering NewRelic deploy event"
curl -X POST -H "x-api-key: $NEWRELIC_LICENSE_KEY" \
-d "deployment[app_name]=$AWS_APPLICATION_NAME" \
-d "Deploying version $SHA1 to $AWS_ENVIRONMENT_NAME" https://api.newrelic.com/deployments.xml

echo "All done!"
