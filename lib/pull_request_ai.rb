require 'forwardable'

require 'pull_request_ai/version'
require 'pull_request_ai/engine'

require 'pull_request_ai/util/configuration'

module PullRequestAi
  extend SingleForwardable

  def_delegators :configuration, :openai_api_key

  def self.configure(&block)
    yield configuration
  end

  ##
  # Returns an existing or instantiates a new configuration object.
  def self.configuration
    @configuration ||= Util::Configuration.new
  end

  private_class_method :configuration
end
