source 'https://rubygems.org'

gem 'bootsnap', require: false
gem 'rails', '~> 6.0'

gem 'rails-html-sanitizer'

# Better logging
gem 'lograge'

gem 'sprockets'

gem 'responders' # See https://github.com/plataformatec/responders

gem 'turbolinks'

# Add after upgrade to rails5
gem 'rails-i18n'

# kaminari must be before elasticsearch to work with es
gem 'kaminari'


gem 'elasticsearch', '~> 7.1'       # Upgrade to 5.x (Can do 6.x as soon as elasticsearch-rails is 6.x compatible)
gem 'elasticsearch-rails', '~> 7.1' # 5.x should be compatible with 6.x
gem 'elasticsearch-model', '~> 7.1' # 5.x should be compatible with 6.x # rubocop:disable Bundler/OrderedGems
gem 'elasticsearch-dsl'             # rubocop:disable Bundler/OrderedGems

# Nice progressbar to use in rake tasks
gem 'ruby-progressbar', require: false

gem 'mysql2', '~> 0.5.0'

gem 'jbuilder', '~> 2.0'

gem 'haml'
gem 'haml-rails'

gem 'autoprefixer-rails'
# gem 'bootstrap-sass', '~> 3.3'
gem 'bootstrap'

# To include the icon helper.
gem 'font-awesome-sass', '~> 5.8'
gem 'sassc-rails'

gem 'mini_magick'

gem 'fog-aws' # , require: false
# gem 'fog-rackspace' # , require: false
gem 'leifcr-refile', require: 'refile/rails' # Use leifcr-refile until new version is released
gem 'leifcr-refile-fog'
gem 'leifcr-refile-mini_magick', require: 'refile/mini_magick'

gem 'carrierwave'

gem 'interactor-rails', '~> 2.0'

# For CC payments
# gem 'stripe'

# For sending data from backend into js
gem 'gon'

# For states: https://github.com/gocardless/statesman
gem 'statesman'

# For unique id's on orders, carts etc, since integers can be easily found
gem 'mysql-binuuid-rails'

# CSP setup/reporting, (rails 5.2+ has this included)
# gem 'secure_headers'

# Asset precompilation
# Using webpacker for js
gem 'webpacker', '~> 5.0'

# Error Tracking
# gem 'sentry-raven'

gem 'rollbar'

group :staging, :production do
  # Profiler
  # Note: Cannot use skylight in production, as it cannot filter out kubernetes alive checks
  # gem 'skylight'

  # Use to passenger for serving static assets
  # For using puma in production, the rails deployment package must include
  # a 'sidekart nginx' to serve static assets, or you must include
  gem 'passenger', require: 'phusion_passenger/rack_handler'
  gem 'sidekiq-alive-next' # Supports sidekiq 7+
end

# gem 'delayed_job'
# gem 'delayed_job_active_record'

gem 'sidekiq'

# To ensure we don't do multiple requests for klarna if one is already in queue..
gem 'activejob-uniqueness'

# Forms
gem 'simple_form', '~> 5.0'
gem 'country_select' # rubocop:disable Bundler/OrderedGems - countries must be after country_select
gem 'countries' # rubocop:disable Bundler/OrderedGems

# Authentication
# See https://github.com/heartcombo/devise/issues/5326#issuecomment-776627602
# Switch back to released version, as soon as new version is released
# gem "devise", github: "heartcombo/devise", branch: "master"
gem 'devise'
gem 'devise-i18n'

gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'
gem 'omniauth-linkedin-oauth2'
gem 'omniauth-rails_csrf_protection'

# For accessing google apis (YouTube etc)
gem 'google-api-client'

# Authorization
gem 'pundit'

# For simple search, ransack can be used
# gem 'ransack'

# For sitemaps
gem 'sitemap_generator'

group :development, :test do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'puma'
  gem 'rspec-rails', '~> 5.0' # , group: [:development, :test]
  gem 'rspec-retry'

  gem 'bullet' # n+1 queries finder
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'

  gem 'capybara-screenshot'

  gem 'timecop'

  gem 'capybara-selenium'

  # For testing on selenium against ff, chrome, edge and ie
  gem 'webdrivers'

  gem 'rails-controller-testing'

  # Alternative: change to https://github.com/elgalu/docker-selenium
  # For using real chrome/ff browsers through selenium

  # Coverage
  # gem 'simplecov', require: false
  # gem 'simplecov-rcov', require: false

  # Notificiations sent to growl through gntp
  gem 'ruby_gntp'
end

# Nesting
gem 'awesome_nested_set'

# Ordering

gem 'ranked-model'

# NOTE: slugs from friendly_id must be saved in history with paper_trail, or stored in separate table to allow historical routing
gem 'friendly_id'

gem 'hashie' # used by content on json data
gem 'hashie-forbidden_attributes' # To fix strong params issue
# Alternative: use virtus models instead of hashie serialized cols
# gem 'virtus'

# For inlining css on emails (gmail + others remove css styles...)
gem 'inky-rb', require: 'inky'
gem 'premailer-rails'

gem 'terminal-table'

# For truncating/word_wrapping tables. (Facets has a lot of ruby extension goodies...)
gem 'facets', require: false

# For validating email addresses
gem 'valid_email2'

# For publish/draft/versining, paper_trail is used
gem 'paper_trail'

# Caching in memcached through dalli
gem 'dalli'

# Connection pooling for dalli/puma, when running multi threaded:
# See https://github.com/petergoldstein/dalli#multithreading-and-rails
gem 'connection_pool'

# Use Faraday for requests?
gem 'excon'   # for using excon faraday adapter
gem 'faraday' # do http requests over tons of adapters...

gem 'enumerize'

# For prettier pagination in urls
gem 'routing-filter', github: 'normedia/routing-filter', branch: 'rails-6.1'

# For truncating html
gem 'truncate_html'

gem 'slack-ruby-client'

gem 'easy-box-packer', github: 'leifcr/easy-box-packer'

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'

  gem 'i18n-tasks' # To check for missing/unused translations

  # Note, remove binding_of_caller and/or better_errors if debugging is slow
  # See https://github.com/charliesome/better_errors/issues/341
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'nokogiri' # Needed for data-import.
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # For reloading during devel
  gem 'guard-livereload', require: false
  gem 'guard-rspec', require: false

  gem 'thor'

  # Annotate all the models :)
  gem 'annotate', require: false

  # Allow mailer_preview to have access to params
  # gem 'mailer_preview_request_model'

  # Better ruby/rails console
  gem 'pry-rails'
  gem 'pry-toys'
  # Issues with rails 6 + pry-byebug
  # gem 'pry-byebug'

  gem 'rubocop-rails'
end
