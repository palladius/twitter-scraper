#!/bin/bash

export RAILS_ENV=test
export RUBYOPT="-W0"
#rspec

set -e

#rake db:setup
echodo rake db:fixtures:load
#bundle exec rake --tasks | egrep 'hello|sbirc'

#echodo bundle exec
rake db:sbirciatina
rake db:popola_test  RAILS_ENV=test
