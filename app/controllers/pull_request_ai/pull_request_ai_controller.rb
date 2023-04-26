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
      client.flatten_current_changes(prepare_params[:branch]).fmap do |changes|
        if changes.empty?
          render(json: { notice: "No changes between branches. Please check the destination branch." }, status: :unprocessable_entity)
        else
          client.suggested_description(prepare_params[:type], changes).fmap do |description|
            response = { description: description }
            client.current_opened_pull_requests(prepare_params[:branch]).fmap do |open_prs|
              response[:github_enabled] = true
              open_pr = open_prs.first
              if open_pr
                response[:open_pr] = {
                  number: open_pr['number'],
                  title: open_pr['title'],
                  description: open_pr['body']
                }
              end
              render(json: response)
            end.or do |_|
              response[:github_enabled] = false
              render(json: response)
            end
          end.or do |error|
            render(json: { errors: error }, status: :unprocessable_entity)
          end
        end
      end.or do |error|
        render(json: { errors: error }, status: :unprocessable_entity)
      end
    end

    def create
      result = client.open_pull_request(
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

    def prepare_params
      params.require(:pull_request_ai).permit(:branch, :type)
    end

    def pr_params
      params.require(:pull_request_ai).permit(:number, :branch, :type, :title, :description)
    end
  end
end
