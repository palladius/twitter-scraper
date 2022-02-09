#!/bin/bash

export RAILS_ENV=production

echo "[ENTRYPOINT8080] Im not sure if I should have .env baked INSIDE the docker image or not. I presume I should NOT right? Well then let me add it to .dockerignore then"
ls -al 
echo "[ENTRYPOINT8080] MESSAGGIO_OCCASIONALE: $MESSAGGIO_OCCASIONALE"
echo "[ENTRYPOINT8080] DATABASE_URL REMOVEME: $DATABASE_URL"

rake db:migrate
rake assets:precompile

rails s -p 8080 -b 0.0.0.0