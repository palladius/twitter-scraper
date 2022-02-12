

# ricc stuff

require 'socket'

hostname = Socket.gethostname

HOSTNAME = hostname 

LOCATION = ENV["APP_LOCATION"] ?  ENV["APP_LOCATION"] : HOSTNAME

APP_VERSION = ENV["APP_VERSION"] ? 
    "ENV_#{ ENV["APP_VERSION"]}" :
    "FILEREAD_#{File.read "./VERSION"}"


# addon_in_the_end
# .append(wordle_regex_append_to_the_end)
addon =  Rails.application.config_for(:wordle_regexes, env: "addon_in_the_end")
WORDLE_REGEXES = Rails.application.config_for(:wordle_regexes, env: "default").concat(addon).flatten.select{|el| el.key?(:return) rescue false}
#p WORDLE_REGEXES.map{|x| x[:return] rescue :error}
