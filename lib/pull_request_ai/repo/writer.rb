require 'dry/monads'
require 'httparty'

module PullRequestAi
  module Repo
    class Writer
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

      def open_pull_request(to_branch, title, description)
        current_branch = reader.current_branch.or { |error|
          return Failure(error)
        }
        
        slug = reader.repository_slug.or { |error|
          return Failure(error)  
        }

        content = {
          title: title,
          body: description,
          head: current_branch.value!,
          base: to_branch
        }.to_json

        request(slug.value!, content)
      end

      private 

      def reader 
        @reader ||= Reader.new
      end

      def request(slug, content)
        response = HTTParty.send(
          :post,
          build_uri(slug),
          headers: headers,
          body: content,
        )

        # https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#create-a-pull-request
        if response.code.to_i == 201
          Success(response.parsed_response)
        else 
          errors = response.parsed_response['errors']&.map { |error| error['message'] }&.join(' ')
          errors.to_s.empty? ? Failure(:failed_on_github_api_endpoint) : Failure(errors)
        end
      end

      def build_uri(slug)
        "#{github_api_endpoint}/repos/#{slug}/pulls"
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