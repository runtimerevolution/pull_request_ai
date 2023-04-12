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

    def repo
      @repo ||= PullRequestAi::Repo::Client.new
    end

    def destination_branches
      repo.destination_branches
    end

    def open_pull_request(to_branch, title, description)
      repo.open_pull_request(to_branch, title, description)
    end

    def ask_chat_description(to_branch, type)
      repo_client.flatten_current_changes_to(to_branch).bind do |changes|
        chat = PullRequestAi.OpenAi::Chat.new(type, changes)
        chat.chat!
      end
    end

    def ask_chat_description_and_open_pull_request(to_branch, type, title)
      ask_chat_description(to_branch, type).bind do |description|
        open_pull_request(to_branch, title, description)
      end
    end
  end
end
