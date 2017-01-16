#!/bin/bash
set -eu -o pipefail

SHA1=$1
AWS_APPLICATION_NAME=$2
export AWS_ENVIRONMENT_NAME=$3
STATIC_BUCKET=$4
export ENV_URL=$5

function ebextensions_setup() {
    echo 'Setting up configuration for Papertrail logging'
    export PAPERTRAIL_HOST=$(cut -d ":" -f 1 <<< $ENV_URL)
    export PAPERTRAIL_PORT=$(cut -d ":" -f 2 <<< $ENV_URL)
    export PAPERTRAIL_SYSTEM=$AWS_ENVIRONMENT_NAME
    cat .ebextensions/03_papertrail.config | envsubst '$PAPERTRAIL_HOST:$PAPERTRAIL_PORT:$PAPERTRAIL_SYSTEM' >temp
    mv temp .ebextensions/03_papertrail.config

    echo 'Applying environment-specific configuration in .ebextensions'
    envsubst '$AWS_ENVIRONMENT_NAME' <.ebextensions/04_newrelic.config >temp
    mv temp .ebextensions/04_newrelic.config
    envsubst '$ENV_URL' <.ebextensions/05_nginx_proxy.config >temp
    mv temp .ebextensions/05_nginx_proxy.config
}

function sync_s3() {
    echo 'Shipping static assets to S3...'
    id=$(docker create soutech/champaign_web:$SHA1)
    docker cp $id:/champaign/public/assets statics
    aws s3 sync statics/ s3://$STATIC_BUCKET/assets/
    docker cp $id:/champaign/public/webpack statics-webpack
    aws s3 sync statics-webpack/ s3://$STATIC_BUCKET/webpack/
    # aws s3 cp /tmp/foo/ s3://bucket/ --recursive \
    # --exclude "*" --include "assets" --include "webpack"

    echo 'Shipping source bundle to S3...'
    zip -r9 $SHA1-config.zip Dockerrun.aws.json ./.ebextensions/
    SOURCE_BUNDLE=$SHA1-config.zip
    aws configure set default.region $AWS_REGION
    aws s3 cp $SOURCE_BUNDLE s3://$EB_BUCKET/$SOURCE_BUNDLE
}

function application_status() {
    echo $(aws elasticbeanstalk describe-environments --environment-names $1  2>/dev/null \
    | jq -r '.Environments[].Status')
}

function wait_until_ready() {
    STATUS="$(application_status $AWS_ENVIRONMENT_NAME)"
    echo $1
    while [[ "$STATUS" != "Ready" ]]
    do
        sleep 15s
        STATUS="$(application_status $AWS_ENVIRONMENT_NAME)"
        echo -n "."
    done
}

function get_version() {
    echo $(aws elasticbeanstalk describe-environments --environment-names $1  2>/dev/null \
    | jq -r '.Environments[].VersionLabel')
}

function count_versions() {
    # Get all applications with the specified version label and look at the length of the ApplicationVersions array
    echo $(aws elasticbeanstalk describe-application-versions --application-name $AWS_APPLICATION_NAME --version-label $SHA1 2>/dev/null | jq -r '.ApplicationVersions | length')
}

function create_version() {
    if [[ $(count_versions) -ne 0 ]]; then
        echo 'Application version already exists. Deploying existing application version.'
    else
        echo 'Creating new application version...'
        aws elasticbeanstalk create-application-version --application-name "$AWS_APPLICATION_NAME" \
          --version-label $SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$SOURCE_BUNDLE
    fi
}

function deploy() {
    echo 'Updating environment...'
    aws elasticbeanstalk update-environment --environment-name $AWS_ENVIRONMENT_NAME \
        --version-label $SHA1
    wait_until_ready "Waiting for deploy to finish. "
    VERSION_LABEL="$(get_version $AWS_ENVIRONMENT_NAME)"
    if [ "$VERSION_LABEL" == "$SHA1" ]; then
        echo ""
        echo "Application deployed succesfully. Triggering NewRelic deploy event."
        new_relic_deploy
        echo "All done!"
    else
        echo "Deploy failed - application version reverted. Check out deployment logs for details."
        exit 1
    fi
}

function new_relic_deploy() {
    curl -X POST -H "x-api-key: $NEWRELIC_LICENSE_KEY" \
    -d "deployment[app_name]=$AWS_APPLICATION_NAME" \
    -d "Deploying version $SHA1 to $AWS_ENVIRONMENT_NAME" https://api.newrelic.com/deployments.xml
}


ebextensions_setup
sync_s3
create_version
wait_until_ready "Waiting for application state to clear up for deployment. "
deploy
