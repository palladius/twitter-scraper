

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


# yellow() defined in config/boot
