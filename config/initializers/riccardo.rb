

# ricc stuff

require 'socket'

hostname = Socket.gethostname

HOSTNAME = hostname

LOCATION = ENV["APP_LOCATION"] ?  ENV["APP_LOCATION"] : HOSTNAME

APP_VERSION = ENV["APP_VERSION"] ?
    "#{ ENV["APP_VERSION"]}_E" :
    "#{File.read("./VERSION").strip}_F"


# Wiordle Regexes, in two stages.
addon =  Rails.application.config_for(:wordle_regexes, env: "addon_in_the_end")
WORDLE_REGEXES = Rails.application.config_for(:wordle_regexes, env: "default").concat(addon).flatten.select{|el| el.key?(:return) rescue false}

# #if [ -f /.dockerenv ]; then
# echo "I'm inside matrix ;(";
# else
#     echo "I'm living in real world!";
# fi
# https://stackoverflow.com/questions/23513045/how-to-check-if-a-process-is-running-inside-docker-container
AM_I_ON_DOCKER = File.exists?('/.dockerenv')
# yellow() defined in config/boot

