#!/bin/bash

source .env

#DATABASE_URL=postgres://twitter-scraper:MannaggiaUPatataughTwitter@34.65.100.166:5432/twitter-scraper-prod
#APP_VERSION=`cat VERSION`
#MESSAGGIO_OCCASIONALE="Evidentemente funge. Sono checkato su GIC e symlinkato dentro .env dentro al mio sito github. Che figo che sono."
#RAILS_LOG_TO_STDOUT=true

DEPLOY_VERSION="1.2_20220209"
VERSION=`cat VERSION`
PROJECT_ID=$(gcloud config get-value project)

# See why of MESSAGGIO_OCCASIONALE weirdness here: https://ahmet.im/blog/mastering-cloud-run-environment-variables/
echodo gcloud run deploy twitter-scraper \
     --set-env-vars="RAILS_LOG_TO_STDOUT=$RAILS_LOG_TO_STDOUT" \
     --set-env-vars="RAILS_SERVE_STATIC_FILES=$RAILS_SERVE_STATIC_FILES" \
     --set-env-vars="^###^MESSAGGIO_OCCASIONALE=$MESSAGGIO_OCCASIONALE,DEPLOY_VERSION=$DEPLOY_VERSION" \
     --set-env-vars="DATABASE_URL=$DATABASE_URL" \
     --set-env-vars="APP_VERSION=$VERSION" \
     --set-env-vars="APP_LOCATION=GCP CloudRun on $PROJECT_ID" \
     --platform managed \
     --region europe-west1 \
     --image "gcr.io/ric-cccwiki/twitter-scraper:v$VERSION" \
     --allow-unauthenticated