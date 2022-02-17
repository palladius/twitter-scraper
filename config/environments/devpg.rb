# Idea copiata da https://nts.strzibny.name/creating-staging-environments-in-rails/

# Just use the production settings
require File.expand_path('../development.rb', __FILE__)

puts yellow "[PostgreS DEV] Bella regaz. Need to troubleshoot weird JOINs which require PostGreS in Dev..."
puts yellow "DEV_CONFIG: ENV: #{ENV.fetch 'DEV_DATABASE_URL'}"
Rails.application.configure do
  # Here override any defaults
  #config.serve_static_files = true
end