# Idea copiata da https://nts.strzibny.name/creating-staging-environments-in-rails/

# Just use the production settings
require File.expand_path('../development.rb', __FILE__)

Rails.application.configure do
  # Here override any defaults
  #config.serve_static_files = true
  puts "Bella regaz. Need to troubleshoot weird JOINs which require PostGreS in DEv..."
end