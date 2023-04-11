require 'forwardable'
require 'httparty'
require 'dry/monads'
require 'rack/attack'
require 'git_clone_url'

require 'pull_request_ai/version'
require 'pull_request_ai/engine'

require 'pull_request_ai/util/configuration'
require 'pull_request_ai/openAi/client'
require 'pull_request_ai/openAi/chat'

require 'pull_request_ai/repo/file'
require "pull_request_ai/repo/client"
require "pull_request_ai/repo/prompt"

module PullRequestAi
  extend SingleForwardable
  def_delegators :configuration, :github_api_endpoint
  def_delegators :configuration, :github_access_token, :github_access_token=
  def_delegators :configuration, :openai_api_key, :openai_api_key=
  def_delegators :configuration, :open_ai_uri
  def_delegators :configuration, :api_version
  def_delegators :configuration, :model, :model=
  def_delegators :configuration, :temperature, :temperature=

  def self.configure(&block)
    yield configuration
  end


  # Returns an existing configuration object or instantiates a new one
  def self.configuration
    @configuration ||= Util::Configuration.new
  end

  private_class_method :configuration
end
