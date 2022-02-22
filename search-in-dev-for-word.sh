#!/bin/bash 
# k4rlheinz
WORD=${1:-palladius}

while true ; do 
    TWITTER_INGEST_SIZE=10 \
        MARSHAL_TO_FILE=true \ 
        RAILS_ENV=development \
        DEBUG=true \
        SEARCH_ONLY_FOR="$WORD" \
        rake db:seed
    sleep 5
done

