#!/bin/bash
set -eu -o pipefail

# Set the url of the braintree token lambda. Production lambda if branch is master, otherwise staging.
export BRAINTREE_TOKEN_URL=$([ $CIRCLE_BRANCH == "master" ] && echo $PRODUCTION_BRAINTREE_TOKEN_URL || echo $STAGING_BRAINTREE_TOKEN_URL)

docker build -t soutech/champaign_web:$CIRCLE_SHA1 .

docker login -u $DOCKER_USER -p $DOCKER_PASS
docker push soutech/champaign_web
