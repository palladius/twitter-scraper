#!/bin/bash

source .env

# 1.3 Had to move DATABASE_URL to PROD_DATABASE_URL or DEV would pick it up and commit to PROD DB by mistake !!! (which is WAI)
# 1.5 Added TWITTER vars so now i can call updates from Cloud Fujnction and not have a client running forever :)

DEPLOY_VERSION="1.5stag_20220226"
VERSION=`cat VERSION`
PROJECT_ID=$(gcloud config get-value project)

# See why of MESSAGGIO_OCCASIONALE weirdness here: https://ahmet.im/blog/mastering-cloud-run-environment-variables/
echodo gcloud run deploy twitter-scraper-staging \
     --set-env-vars="RAILS_LOG_TO_STDOUT=$RAILS_LOG_TO_STDOUT" \
     --set-env-vars="RAILS_SERVE_STATIC_FILES=$RAILS_SERVE_STATIC_FILES" \
     --set-env-vars="^###^MESSAGGIO_OCCASIONALE=[STAGING] $MESSAGGIO_OCCASIONALE,DEPLOY_VERSION=$DEPLOY_VERSION,AT=$(date)" \
     --set-env-vars="DATABASE_URL=$STAGING_DATABASE_URL" \
     --set-env-vars="STAGING_DATABASE_URL=$STAGING_DATABASE_URL" \
     --set-env-vars="PROD_DATABASE_URL=$STAGING_DATABASE_URL" \
     --set-env-vars="APP_VERSION=$VERSION" \
     --set-env-vars="TWITTER_CONSUMER_KEY=$TWITTER_CONSUMER_KEY" \
     --set-env-vars="TWITTER_CONSUMER_SECRET=$TWITTER_CONSUMER_SECRET" \
     --set-env-vars="APP_LOCATION=GCP CloudRun on $PROJECT_ID [STAGING]" \
     --platform managed \
     --region europe-west1 \
     --image "gcr.io/ric-cccwiki/twitter-scraper:v$VERSION" \
     --allow-unauthenticated