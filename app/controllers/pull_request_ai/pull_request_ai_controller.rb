# frozen_string_literal: true

require_dependency 'pull_request_ai/application_controller'

module PullRequestAi
  class PullRequestAiController < ApplicationController
    def new
      @types = [['Feature', :feature], ['Release', :release], ['HotFix', :hotfix]]

      client.destination_branches.fmap do |branches|
        @branches = branches
      end.or do |_|
        @error_message = "Your project doesn't have a repository configured."
      end
    end

    def prepare
      client.ask_chat_description(pr_params[:branch], pr_params[:type]).fmap do |description|
        client.current_opened_pull_requests_to(pr_params[:branch]).fmap do |open_prs|
          if open_prs.empty?
            render(json: { description: description, github_enabled: true })
          else
            open_pr = open_prs.first
            render(json: {
              description: description,
              github_enabled: true,
              opened: {
                number: open_pr['number'],
                title: open_pr['title'],
                description: open_pr['body']
              }
            })
          end
        end.or do |_|
          render(json: { description: description, github_enabled: false })
        end
      end.or do |error|
        render(json: { errors: error }, status: :unprocessable_entity)
      end
    end

    def create
      result = client.open_pull_request_to(
        pr_params[:branch],
        pr_params[:title],
        pr_params[:description]
      )
      proccess_result(result)
    end

    def update
      result = client.update_pull_request(
        pr_params[:number],
        pr_params[:branch],
        pr_params[:title],
        pr_params[:description]
      )
      proccess_result(result)
    end

    private

    def proccess_result(result)
      result.fmap do
        render(json: { success: 'true' })
      end.or do |error|
        render(
          json: { errors: error.to_s.empty? ? 'Something went wrong.' : error.to_s },
          status: :unprocessable_entity
        )
      end
    end

    def client
      @client ||= PullRequestAi::Client.new
    end

    def pr_params
      params.require(:pull_request_ai).permit(:number, :branch, :type, :title, :description)
    end
  end
end
