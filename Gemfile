source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.2"

########################
# Riccardo - definitely need it
gem 'twitter'
gem "chartkick"
gem "groupdate"
gem 'redis' # needed for action cable - if you enable it, but now its disabled.
# postgres, requires installing stuff on Mac/Linux
# Mac:   `brew install libpq`, gem install pg -- --with-pg-config=/usr/local/opt/libpq/bin/pg_config`` # https://gist.github.com/tomholford/f38b85e2f06b3ddb9b4593e841c77c9e
# Linux: See `Dockerfile``
gem "pg"
gem "dotenv"
gem 'dotenv-rails' # , :groups => [:development, :test, :production, :staging ]
gem 'delayed_job_active_record' # sembra vecchiotto ma non richiede Redis https://github.com/collectiveidea/delayed_job_active_record
#gem 'activerecord-spanner-adapter' - damn, doesnt work with activerecord 7.0.1
#/ Riccardo
########################

########################
# Riccardo - MAYBE need it
#gem "ric"
#gem 'sidekiq' # to execute SEEDing as a job externally, am richiede Redis che poi e' un casino...
gem "daemons" # allows to start outside of rails... not sure if i need it: https://github.com/collectiveidea/delayed_job
#/ Riccardo
########################

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.1"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 1.4"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem "ruby-lsp", require: false
  #gem "ruby-lsp", "~> 0.0.4", :group => :development

end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

