# frozen_string_literal: true

require_relative 'boot'

require 'action_controller/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require 'dotenv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require 'pull_request_ai'

Dotenv.load('../../.env')

module Dummy
  class Application < Rails::Application
    config.load_defaults(Rails::VERSION::STRING.to_f)

    # For compatibility with applications that use this config
    config.action_controller.include_all_helpers = false

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
