# frozen_string_literal: true

module PullRequestAi
  module Repo
    class Api
      include Dry::Monads[:result, :do]

      attr_accessor :github_api_endpoint
      attr_accessor :github_access_token

      def initialize(
        github_api_endpoint: nil,
        github_access_token: nil
      )
        @github_api_endpoint = github_api_endpoint || PullRequestAi.github_api_endpoint
        @github_access_token = github_access_token || PullRequestAi.github_access_token
      end

      # https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#list-pull-requests
      def opened_pull_requests(slug, head, base)
        request(:get, slug, '', 200, {
          head: head,
          base: base
        }.to_json)
      end

      # https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#update-a-pull-request
      def update_pull_request(slug, number, base, title, description)
        request(:patch, slug, "/#{number}", 200, {
          title: title,
          body: description,
          state: 'open',
          base: base
        }.to_json)
      end

      # https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#create-a-pull-request
      def open_pull_request(slug, head, base, title, description)
        request(:post, slug, '', 201, {
          title: title,
          body: description,
          head: head,
          base: base
        }.to_json)
      end

      private

      def request(type, slug, suffix, success_code, content)
        url = build_url(slug, suffix)
        response = HTTParty.send(type, url, headers: headers, body: content)
        if response.code.to_i == success_code
          Success(response.parsed_response)
        else
          errors = response.parsed_response['errors']&.map { |error| error['message'] }&.join(' ')
          errors.to_s.empty? ? Failure(:failed_on_github_api_endpoint) : Failure(errors)
        end
      end

      def build_url(slug, suffix)
        "#{github_api_endpoint}/repos/#{slug}/pulls#{suffix}"
      end

      def headers
        {
          'Accept' => 'application/vnd.github+json',
          'Authorization' => "Bearer #{github_access_token}"
        }
      end
    end
  end
end
