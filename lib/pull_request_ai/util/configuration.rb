# frozen_string_literal: true

module PullRequestAi
  module Util
    class Configuration
      attr_accessor :openai_api_key
      attr_accessor :github_access_token
      attr_accessor :bitbucket_access_token

      attr_accessor :openai_api_endpoint
      attr_accessor :github_api_endpoint
      attr_accessor :bitbucket_api_endpoint

      attr_accessor :model
      attr_accessor :temperature
      attr_accessor :http_timeout

      attr_reader :api_version
      attr_reader :rrtools_grouped_gems

      def initialize
        @api_version = 'v1'

        @openai_api_key = ENV['OPENAI_API_KEY']
        @github_access_token = ENV['GITHUB_ACCESS_TOKEN']
        @bitbucket_access_token = ENV['BITBUCKET_ACCESS_TOKEN']

        @openai_api_endpoint = 'https://api.openai.com'
        @github_api_endpoint = 'https://api.github.com'
        @bitbucket_api_endpoint = 'https://api.bitbucket.org'

        @model = 'gpt-3.5-turbo'
        @temperature = 0.8
        @http_timeout = 60

        @rrtools_grouped_gems = Rails.application.routes.routes.select do |prop|
          prop.defaults[:group] == 'RRTools'
        end.collect do |route|
          {
            name: route.name,
            path: route.path.build_formatter.instance_variable_get('@parts').join
          }
        end || []
      end
    end
  end
end
