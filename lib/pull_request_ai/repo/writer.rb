require 'dry/monads'
require 'octokit'

module PullRequestAi
  module Repo
    class Writer
      include Dry::Monads[:result, :do]

      attr_accessor :github_access_token

      def initialize(github_access_token: nil)
        @github_access_token = github_access_token || PullRequestAi.github_access_token
      end

      def open_pull_request(to_branch, title, description)
        current_branch = reader.current_branch.or { |error|
          return Failure(error)
        }
        
        slug = reader.repository_slug.or { |error|
          return Failure(error)  
        }

        begin
          pr = client.create_pull_request(slug.value!, current_branch.value!, to_branch, title, description)
          Success(pr)
        rescue Octokit::NotFound => error
          Failure(:github_not_found)
        rescue Octokit::Unauthorized => error
          Failure(:github_unauthorized)
        end
      end

      private 

      def reader 
        @reader ||= Reader.new
      end

      def client
        @client ||= Octokit::Client.new(access_token: github_access_token)
      end

    end
  end
end