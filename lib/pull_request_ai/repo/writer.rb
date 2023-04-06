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
          pr = client.create_pull_request(slug.value!, to_branch, current_branch.value!, title, description)
          Success(pr)
        rescue Octokit::NotFound => error
          # Access token nil or remote repository doesn't exist for this user.
          Failure(:github_not_found)
        rescue Octokit::Unauthorized => error
          # Invalid access token.
          Failure(:github_unauthorized)
        rescue Octokit::UnprocessableEntity => error
          # Probably the current branch is not yet pushed to server.
          # Or the destination branch already contains the commits from current branch.
          Failure(:github_unprocessable_entity)
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