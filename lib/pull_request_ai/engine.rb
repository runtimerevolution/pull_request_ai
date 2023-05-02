# frozen_string_literal: true

module PullRequestAi
  class Engine < ::Rails::Engine
    isolate_namespace PullRequestAi

    config.assets.precompile += ['application.js']
    config.assets.precompile += ['notifications.js']
    config.assets.precompile += ['pull_request_ai/application.css']
  end
end
