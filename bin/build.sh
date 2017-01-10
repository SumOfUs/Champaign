#!/bin/bash

export RAILS_ENV=production
export NODE_ENV=production

# Build front end bundle
yarn run build

# Precompile assets
bundle exec rake assets:download_and_precompile[$CUSTOM_ASSETS_URL,$CUSTOM_ASSETS_CREDENTIALS,$CIRCLE_BRANCH,$EXTERNAL_ASSET_PATHS]

# Build docker image
docker build -t soutech/champaign_web:$CIRCLE_SHA1 --build-arg ci=true .

# Publish the image
docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASS
docker push soutech/champaign_web
