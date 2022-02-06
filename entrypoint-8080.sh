#!/bin/bash

export RAILS_ENV=production
rake db:migrate
rake assets:precompile
rails s -p 8080 -b 0.0.0.0