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
      client.current_opened_pull_requests_to(pr_params[:branch]).bind do |open_prs|
        client.ask_chat_description(pr_params[:branch], pr_params[:type]).fmap do |description|
          if open_prs.empty?
            return render(json: { description: description })
          else
            open_pr = open_prs.first
            return render(json: {
              description: description, 
              opened: {
                number: open_pr.dig('number'),
                title: open_pr.dig('title'),
                description: open_pr.dig('body')
            }})
          end
        end
      end.or do |error|
        render(json: { errors: error }, status: :unprocessable_entity)
      end
    end

    def create
      result = client.open_pull_request_to(
        pr_params[:branch], pr_params[:title], pr_params[:description]
      )

      result.fmap do
        render(json: { success: 'true' })
      end.or do |error|
        render(
          json: { errors: error.to_s.empty? ? 'Something went wrong.' : error.to_s },
          status: :unprocessable_entity
        )
      end
    end

    private

    def client
      @client ||= PullRequestAi::Client.new
    end

    def pr_params
      params.require(:pull_request_ai).permit(:branch, :type, :title, :description)
    end
  end
end
