# frozen_string_literal: true

module PullRequestAi
  module GitHub
    # A client to communicate with the GitHub API.
    class Client
      attr_accessor :api_endpoint
      attr_accessor :access_token
      attr_reader   :http_timeout

      ##
      # Initializes the client.
      def initialize(
        api_endpoint: nil,
        access_token: nil
      )
        @api_endpoint = api_endpoint || PullRequestAi.github_api_endpoint
        @access_token = access_token || PullRequestAi.github_access_token
        @http_timeout = PullRequestAi.http_timeout
      end

      ##
      # Requests the list of Open Pull Requests using the GitHub API.
      # The slug combines the repository owner name and the repository name.
      # The query contains the head and base to filter the results.
      # Notice:
      # On GitHub it is only possible to have one PR open with the same head and base, despite the result being a list.
      # https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#list-pull-requests
      def opened_pull_requests(slug, head, base)
        query = {
          head: "#{slug.split(":").first}:#{head}",
          base: base
        }
        url = build_url(slug)
        request(:get, url, query, {})
      end

      ##
      # Request to update the existing Pull Request using the GitHub API.
      # The slug combines the repository owner name and the repository name.
      # It requires the Pull Request number to modify it. The base, title, and description can be modified.
      # Notice:
      # We don't have logic to change the base on the UI.
      # https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#update-a-pull-request
      def update_pull_request(slug, number, base, title, description)
        body = {
          title: title,
          body: description,
          state: 'open',
          base: base
        }.to_json
        url = build_url(slug, "/#{number}")
        request(:patch, url, {}, body)
      end

      ##
      # Request to open a new Pull Request using the GitHub API.
      # The slug combines the repository owner name and the repository name.
      # It requires the head (destination branch), the base (current branch), the title, and a optional description.
      # https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#create-a-pull-request
      def open_pull_request(slug, head, base, title, description)
        body = {
          title: title,
          body: description,
          head: head,
          base: base
        }.to_json
        url = build_url(slug)
        request(:post, url, {}, body)
      end

      private

      def request(type, url, query, body)
        response = HTTParty.send(
          type, url, headers: headers, query: query, body: body, timeout: http_timeout
        )

        if response.success?
          Dry::Monads::Success(response.parsed_response)
        else
          errors = response.parsed_response['errors']&.map { |error| error['message'] }&.join(' ')
          Error.failure(:failed_on_github_api_endpoint, errors.to_s.empty? ? nil : errors)
        end
      rescue Net::ReadTimeout
        Error.failure(:connection_timeout)
      end

      def build_url(slug, suffix = '')
        "#{api_endpoint}/repos/#{slug}/pulls#{suffix}"
      end

      def headers
        {
          'Accept' => 'application/vnd.github+json',
          'Authorization' => "Bearer #{access_token}"
        }
      end
    end
  end
end
