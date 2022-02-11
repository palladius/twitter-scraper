#!/bin/bash

export RAILS_ENV=test
export RUBYOPT="-W0"
#rspec

set -e

echodo rake db:fixtures:load
bundle exec rake --tasks | egrep 'hello|sbirc'

#echodo bundle exec
rake db:sbirciatina
