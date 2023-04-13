# frozen_string_literal: true

module PullRequestAi
  class Client
    def initialize(
      github_api_endpoint: nil,
      github_access_token: nil,
      openai_api_key: nil,
      open_ai_uri: nil,
      api_version: nil,
      model: nil,
      temperature: nil
    )
      PullRequestAi.configuration.github_api_endpoint = github_api_endpoint if github_api_endpoint
      PullRequestAi.configuration.github_access_token = github_access_token if github_access_token
      PullRequestAi.configuration.openai_api_key = openai_api_key if openai_api_key
      PullRequestAi.configuration.open_ai_uri = open_ai_uri if open_ai_uri
      PullRequestAi.configuration.api_version = api_version if api_version
      PullRequestAi.configuration.model = model if model
      PullRequestAi.configuration.temperature = temperature if temperature
    end

    def repo_reader
      @repo_reader ||= PullRequestAi::Repo::Reader.new
    end

    def repo_api
      @repo_api ||= PullRequestAi::Repo::Api.new
    end

    def current_opened_pull_requests
      repo_reader.repository_slug.bind do |slug|
        repo_reader.current_branch.bind do |branch|
          repo_api.opened_pull_requests(slug, branch)
        end
      end
    end

    def destination_branches
      repo_reader.destination_branches
    end

    def open_pull_request_to(base, title, description)
      repo_reader.repository_slug.bind do |slug|
        repo_reader.current_branch.bind do |branch|
          repo_api.open_pull_request(slug, branch, base, title, description)
        end
      end
    end

    def ask_chat_description(to_branch, type)
      repo_reader.flatten_current_changes_to(to_branch).bind do |changes|
        PullRequestAi::OpenAi::Interpreter.chat!(type, changes)
      end
    end
  end
end
