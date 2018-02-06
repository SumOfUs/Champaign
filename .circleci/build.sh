#!/bin/bash
set -eu -o pipefail

export RAILS_ENV=production
export NODE_ENV=production

# Set the url of the braintree token lambda. Production lambda if branch is master, otherwise staging.
# TODO: use $CIRCLE_STAGE or $CIRCLE_JOB to check for production deployment
export BRAINTREE_TOKEN_URL=$([ $CIRCLE_BRANCH == "master" ] && echo $PRODUCTION_BRAINTREE_TOKEN_URL || echo $STAGING_BRAINTREE_TOKEN_URL)

# Precompile assets
bundle exec rake assets:download_and_precompile[$CUSTOM_ASSETS_URL,$CUSTOM_ASSETS_CREDENTIALS,$CIRCLE_BRANCH,$EXTERNAL_ASSET_PATHS]

# Build docker image
docker build -t soutech/champaign_web:$CIRCLE_SHA1 --build-arg ci=true circleci-champaign/

# Publish the image
docker login -u $DOCKER_USER -p $DOCKER_PASS
docker push soutech/champaign_web
