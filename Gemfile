source 'https://rubygems.org'
ruby '2.1.2'

gem 'rails', '4.1.6'
gem 'haml-rails'
gem 'bcrypt', '~> 3.1.7'
gem 'mongoid', '~> 4.0.0', github: 'mongoid/mongoid'
gem 'bson_ext'
# after bundle mongoid and bson_ext run rails mongoid config script

gem 'kaminari'
gem 'sucker_punch'
# after bundle
#   rails g kaminari:config
#   rails g kaminari:views default -e haml

gem 'elasticsearch-model'
gem 'elasticsearch-rails'

gem 'mandrill-api'
gem 'geoip', '~> 1.4.0'

# add exception_notifier http://amberonrails.com/rails-exception_notification-setup/
#    https://github.com/smartinez87/exception_notification
# or https://github.com/rails/exception_notification

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

group :development do
  gem 'spring'
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_19, :mri_20, :mri_21, :rbx]
  gem 'html2haml'
  #gem 'quiet_assets'
  #gem 'pry-rails'
end

# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier', '>= 1.3.0'

# Use jquery as the JavaScript library
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

