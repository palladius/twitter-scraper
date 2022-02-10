

# ricc stuff

require 'socket'

hostname = Socket.gethostname

HOSTNAME = hostname 

LOCATION = ENV["APP_LOCATION"] ?  ENV["APP_LOCATION"] : HOSTNAME

APP_VERSION = ENV["APP_VERSION"] ? 
    "ENV_#{ ENV["APP_VERSION"]}" :
    "FILEREAD_#{File.read "./VERSION"}"