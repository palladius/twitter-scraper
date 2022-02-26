#!/bin/bash

source .env

# 1.0 just playing around I'd be surprised if it worked on first time! :)


DEPLOY_VERSION="1.0"
VERSION=`cat VERSION`
HYPHENED_VERSION=$(echo $VERSION | sed -e 's/\./-/g')
PROJECT_ID=$(gcloud config get-value project)

APPIMAGE=gcr.io/ric-cccwiki/twitter-scraper:v$VERSION

# See why of MESSAGGIO_OCCASIONALE weirdness here: https://ahmet.im/blog/mastering-cloud-run-environment-variables/
# echodo gcloud run deploy twitter-scraper-staging \
#      --set-env-vars="RAILS_LOG_TO_STDOUT=$RAILS_LOG_TO_STDOUT" \
#      --set-env-vars="RAILS_SERVE_STATIC_FILES=$RAILS_SERVE_STATIC_FILES" \
#      --set-env-vars="^###^MESSAGGIO_OCCASIONALE=[STAGING] $MESSAGGIO_OCCASIONALE,DEPLOY_VERSION=$DEPLOY_VERSION,AT=$(date)" \
#      --set-env-vars="DATABASE_URL=$STAGING_DATABASE_URL" \
#      --set-env-vars="STAGING_DATABASE_URL=$STAGING_DATABASE_URL" \
#      --set-env-vars="PROD_DATABASE_URL=$STAGING_DATABASE_URL" \
#      --set-env-vars="APP_VERSION=$VERSION" \
#      --set-env-vars="TWITTER_CONSUMER_KEY=$TWITTER_CONSUMER_KEY" \
#      --set-env-vars="TWITTER_CONSUMER_SECRET=$TWITTER_CONSUMER_SECRET" \
#      --set-env-vars="APP_LOCATION=GCP CloudRun on $PROJECT_ID [STAGING]" \
#      --platform managed \
#      --region europe-west1 \
#      --image "gcr.io/ric-cccwiki/twitter-scraper:v$VERSION" \
#      --allow-unauthenticated


# https://cloud.google.com/deploy/docs/deploy-app-gke
echodo gcloud deploy releases create auto-riccardo-release-v$HYPHENED_VERSION \
	--region=europe-west1 \
	--delivery-pipeline=twitter-parser \
	--images=my-app-image=$APPIMAGE