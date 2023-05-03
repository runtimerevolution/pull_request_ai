# frozen_string_literal: true

module PullRequestAi
  module Bitbucket
    # A client to communicate with the Bitbucket API.
    class Client < PullRequestAi::Repo::Client
      attr_accessor :api_endpoint
      attr_accessor :app_password
      attr_accessor :username
      attr_reader   :http_timeout

      ##
      # Initializes the client.
      def initialize(
        api_endpoint: nil,
        app_password: nil,
        username: nil
      )
        @api_endpoint = api_endpoint || PullRequestAi.bitbucket_api_endpoint
        @app_password = app_password || PullRequestAi.bitbucket_app_password
        @username = username || PullRequestAi.bitbucket_username
        @http_timeout = PullRequestAi.http_timeout
      end

      ##
      # Requests the list of Open Pull Requests using the Bitbucket API.
      # The slug combines the repository owner name and the repository name.
      # The query contains the source and destination to filter the results.
      #
      # https://developer.atlassian.com/cloud/bitbucket/rest/api-group-pullrequests/#api-repositories-workspace-repo-slug-pullrequests-get
      def opened_pull_requests(slug, head, base)
        query = {
          q: "source.branch.name = \"#{head}\" AND destination.branch.name = \"#{base}\""
        }
        url = build_url(slug)
        request(:get, url, query, {})
      end

      ##
      # Request to update the existing Pull Request using the Bitbucket API.
      # The slug combines the repository owner name and the repository name.
      # It requires the Pull Request id to modify it. The destination, title, and description can be modified.
      # Notice:
      # We don't have logic to change the base on the UI.
      # https://developer.atlassian.com/cloud/bitbucket/rest/api-group-pullrequests/#api-repositories-workspace-repo-slug-pullrequests-pull-request-id-put
      def update_pull_request(slug, number, base, title, description)
        body = {
          title: title,
          destination: {
            branch: {
              name: base
            }
          },
          description: description
        }.to_json
        url = build_url(slug, "/#{number}")
        request(:put, url, {}, body)
      end

      ##
      # Request to open a new Pull Request using the GitHub API.
      # The slug combines the repository owner name and the repository name.
      # It requires the head (destination branch), the base (current branch), the title, and a optional description.
      # https://developer.atlassian.com/cloud/bitbucket/rest/api-group-pullrequests/#api-repositories-workspace-repo-slug-pullrequests-post
      def open_pull_request(slug, head, base, title, description)
        body = {
          title: title,
          source: {
            branch: {
              name: head
            }
          },
          destination: {
            branch: {
              name: base
            }
          },
          description: description
        }.to_json
        url = build_url(slug)
        request(:post, url, {}, body)
      end

      private

      def request(type, url, query, body)
        response = HTTParty.send(
          type,
          url,
          headers: headers,
          query: query,
          body: body,
          timeout: http_timeout,
          basic_auth: basic_auth
        )

        if response.success?
          Dry::Monads::Success(response.parsed_response)
        else
          puts response.parsed_response
          error = response.parsed_response.dig('error', 'message')
          Error.failure(:failed_on_bitbucket_api_endpoint, error.to_s.empty? ? nil : error)
        end
      rescue Net::ReadTimeout
        Error.failure(:connection_timeout)
      end

      def build_url(slug, suffix = '')
        "#{api_endpoint}/2.0/repositories/#{slug}/pullrequests#{suffix}"
      end

      def headers
        {
          'Content-Type' => 'application/json'
        }
      end

      def basic_auth
        {
          username: username,
          password: app_password
        }
      end
    end
  end
end
