# frozen_string_literal: true

module PullRequestAi
  module Util
    class Configuration
      attr_accessor :github_access_token
      attr_accessor :openai_api_key
      attr_accessor :model
      attr_accessor :temperature

      attr_reader :open_ai_uri
      attr_reader :api_version

      def initialize
        @api_version = 'v1'.freeze
        @open_ai_uri = 'https://api.openai.com'.freeze
        @model = 'gpt-3.5-turbo'
        @temperature = 1
      end
    end
  end
end