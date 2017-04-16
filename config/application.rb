require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mango
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.assets.precompile += %w( page/* )

    config.time_zone = 'Beijing'
    config.active_record.default_timezone = :utc

    config.generators do |g|
      g.test_framework false
    end

    require "data_factory"
  end
end
