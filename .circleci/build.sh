#!/bin/bash
set -eu -o pipefail

docker build -t soutech/champaign_web:$CIRCLE_SHA1 .

docker login -u $DOCKER_USER -p $DOCKER_PASS
docker push soutech/champaign_web
