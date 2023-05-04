# frozen_string_literal: true

require_dependency 'pull_request_ai/application_controller'

module PullRequestAi
  class PullRequestAiController < ApplicationController
    def new
      @types = [['Feature', :feature], ['Release', :release], ['HotFix', :hotfix]]

      client.destination_branches.fmap do |branches|
        @branches = branches
      end.or do |error|
        @error_message = error.description
      end
    end

    def prepare
      client.flatten_current_changes(prepare_params[:branch]).fmap do |changes|
        if changes.empty?
          render(
            json: { notice: SYMBOL_DETAILS[:no_changes_btween_branches] },
            status: :unprocessable_entity
          )
        else
          client.suggested_description(prepare_params[:type], prepare_params[:summary], changes).fmap do |description|
            response = { description: description }
            client.current_opened_pull_requests(prepare_params[:branch]).fmap do |open_prs|
              response[:remote_enabled] = true
              response[:open_pr] = open_prs.first unless open_prs.empty?
              render(json: response)
            end.or do |_|
              response[:remote_enabled] = false
              render(json: response)
            end
          end.or do |error|
            render(json: { errors: error.description }, status: :unprocessable_entity)
          end
        end
      end.or do |error|
        render(json: { errors: error.description }, status: :unprocessable_entity)
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
      result.fmap do |details|
        render(json: details)
      end.or do |error|
        render(json: { errors: error.description }, status: :unprocessable_entity)
      end
    end

    def client
      @client ||= PullRequestAi::Client.new
    end

    def prepare_params
      params.require(:pull_request_ai).permit(:branch, :type, :summary)
    end

    def pr_params
      params.require(:pull_request_ai).permit(:number, :branch, :type, :title, :description)
    end
  end
end
