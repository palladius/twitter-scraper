# Idea copiata da https://nts.strzibny.name/creating-staging-environments-in-rails/

# Just use the production settings
require File.expand_path('../production.rb', __FILE__)

Rails.application.configure do
  # Here override any defaults
  #config.serve_static_files = true
end