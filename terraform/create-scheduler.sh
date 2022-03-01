#!/bin/bash

# while waiting to terraform all of this, Im going to document all TFable things in this dir :)

#STAGE=prod
# ONE: https://twitter-scraper-v3ydafeb7q-ew.a.run.app/actions/seed_by_search_term
# ALL: https://twitter-scraper-v3ydafeb7q-ew.a.run.app/actions/seed_all
LOCATION=europe-west1
SEARCH_TERM='nerdlegame'

gcloud scheduler jobs create http twitter-parser-seed-all-prod --schedule="1/10 * * * *" --location="$LOCATION" \
  --uri="https://twitter-scraper-v3ydafeb7q-ew.a.run.app/actions/seed_by_search_term" --http-method=GET \
  --description="[PROD] Seed all by CLI"

gcloud scheduler jobs create http twitter-parser-seed-all-stag --schedule="6/10 * * * *" --location="$LOCATION" \
  --uri="https://twitter-scraper-staging-v3ydafeb7q-ew.a.run.app/actions/seed_by_search_term" --http-method=GET  \
  --description="[STAG] Seed all by CLI"

# adding a particular search term: nerdlegame

#URL : https://twitter-scraper-staging-v3ydafeb7q-ew.a.run.app
gcloud scheduler jobs create http twitter-parser-search4$SEARCH_TERM-stag --schedule="4/10 * * * *" --location="$LOCATION" \
  --uri="https://twitter-scraper-staging-v3ydafeb7q-ew.a.run.app/actions/seed_by_search_term?search_term=$SEARCH_TERM&n_tweets=142" --http-method=GET  \
  --description="[STAG] Search for single word '$SEARCH_TERM' by CLI"
