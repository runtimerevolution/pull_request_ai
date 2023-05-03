# frozen_string_literal: true

module PullRequestAi
  module Repo
    class Client
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
            when 'bitbucket.com'
              PullRequestAi::Bitbucket::Client.new
            else
              PullRequestAi::Repo::Client.new
          end
        end
      end
    end
  end
end