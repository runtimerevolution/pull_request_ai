# frozen_string_literal: true

module PullRequestAi
  class Engine < ::Rails::Engine
    isolate_namespace PullRequestAi

    config.assets.precompile += ['application.js']
  end
end
