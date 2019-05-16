#!/bin/bash

ENVIRONMENT=production
REPOSITORY=https://github.com/SumOfUs/Champaign
USERNAME=CircleCI

echo "Registering deploy with Airbrake"
echo "Airbrake Project ID: ${AIRBRAKE_PROJECT_ID}"

curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"environment":"'${ENVIRONMENT}'","username":"'${USERNAME}'","repository":"'${REPOSITORY}'","revision":"'${CIRCLE_SHA1}'"}' \
  "https://airbrake.io/api/v4/projects/${AIRBRAKE_PROJECT_ID}/deploys?key=${AIRBRAKE_PROJECT_KEY}"
