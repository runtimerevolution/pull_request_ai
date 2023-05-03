# frozen_string_literal: true

module PullRequestAi
  class Client
    def initialize(
      github_api_endpoint: nil,
      github_access_token: nil,
      openai_api_key: nil,
      openai_api_endpoint: nil,
      api_version: nil,
      model: nil,
      temperature: nil
    )
      PullRequestAi.configuration.github_api_endpoint = github_api_endpoint if github_api_endpoint
      PullRequestAi.configuration.github_access_token = github_access_token if github_access_token
      PullRequestAi.configuration.openai_api_key = openai_api_key if openai_api_key
      PullRequestAi.configuration.openai_api_endpoint = openai_api_endpoint if openai_api_endpoint
      PullRequestAi.configuration.api_version = api_version if api_version
      PullRequestAi.configuration.model = model if model
      PullRequestAi.configuration.temperature = temperature if temperature
    end

    def repo_reader
      @repo_reader ||= PullRequestAi::Repo::Reader.new
    end

    def github_client
      @github_client ||= PullRequestAi::GitHub::Client.new
    end

    def ai_client
      @ai_client ||= PullRequestAi::OpenAi::Client.new
    end

    def ai_interpreter
      @ai_interpreter ||= PullRequestAi::OpenAi::Interpreter.new
    end

    def current_opened_pull_requests(base)
      repo_reader.repository_slug.bind do |slug|
        repo_reader.current_branch.bind do |branch|
          github_client.opened_pull_requests(slug, branch, base)
        end
      end
    end

    def destination_branches
      repo_reader.destination_branches
    end

    def open_pull_request(to_base, title, description)
      repo_reader.repository_slug.bind do |slug|
        repo_reader.current_branch.bind do |branch|
          github_client.open_pull_request(slug, branch, to_base, title, description)
        end
      end
    end

    def update_pull_request(number, base, title, description)
      repo_reader.repository_slug.bind do |slug|
        github_client.update_pull_request(slug, number, base, title, description)
      end
    end

    def flatten_current_changes(to_branch)
      repo_reader.flatten_current_changes(to_branch)
    end

    def suggested_description(type, summary, changes)
      chat_message = ai_interpreter.chat_message(type, summary, changes)
      ai_client.predicted_completions(chat_message)
    end
  end
end
