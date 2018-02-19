#!/bin/bash
set -eu -o pipefail

case "$CIRCLE_BRANCH" in
  'circleci-2')
    export STATIC_BUCKET='champaign-assets-staging'
  ;;
  'production')
    export STATIC_BUCKET='champaign-assets-production'
  ;;
  *)
    export STATIC_BUCKET='champaign-assets-testing'
  ;;
esac

aws s3 sync public/assets s3://$STATIC_BUCKET/assets/ && aws s3 sync public/packs/ s3://$STATIC_BUCKET/packs/
