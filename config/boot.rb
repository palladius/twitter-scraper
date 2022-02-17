ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

# Apparently this is where to put SUPER initial stuff :)
# def yellow(s)
#     #    ' used to colorize everything here..'
#     "[boot] \033[1;33m#{s}\033[0m"
# end

# Copied from..
def yellow(s)   "\e[1;33m#{s}\e[0m" end
def white(s)    "\e[1;37m#{s}\e[0m" end
def azure(s)    "\033[1;36m#{s}\033[0m" end
def red(s)      "\033[1;31m#{s}\033[0m" end
def green(s)    "\033[1;32m#{s}\033[0m" end
def deb(s)      "[DEB]👤 #{s}" end
#👤
