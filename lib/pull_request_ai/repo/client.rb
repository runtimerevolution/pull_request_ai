# frozen_string_literal: true

module PullRequestAi
  module Repo
    class Client
      attr_reader   :http_timeout
      attr_accessor :api_endpoint

      ##
      # Initializes the client.
      def initialize(http_timeout, api_endpoint)
        @http_timeout = http_timeout
        @api_endpoint = api_endpoint
      end

      def opened_pull_requests(slug, head, base)
        Error.failure(:project_not_configured)
      end

      def update_pull_request(slug, number, base, title, description)
        Error.failure(:project_not_configured)
      end

      def open_pull_request(slug, head, base, title, description)
        Error.failure(:project_not_configured)
      end

      class << self
        def client_from_host(host)
          result = host.success? ? host.success : ''
          case result
          when 'github.com'
            PullRequestAi::GitHub::Client.new
          when 'bitbucket.org'
            PullRequestAi::Bitbucket::Client.new
          else
            PullRequestAi::Repo::Client.new
          end
        end
      end
    end
  end
end
