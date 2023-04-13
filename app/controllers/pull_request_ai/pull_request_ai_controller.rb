# frozen_string_literal: true

require_dependency 'pull_request_ai/application_controller'

module PullRequestAi
  class PullRequestAiController < ApplicationController
    before_action :set_defaults, only: [:index, :prepare]
    before_action :set_state, only: [:prepare, :confirm, :create, :result]

    def index; end

    def prepare
      client.ask_chat_description(@branch, @type).fmap do |description|
        redirect_to(pull_request_ai_confirm_path(
          branch: @branch, type: @type, description: description
        ))
      end.or do |error|
        @error_message = error
        render(:index)
      end
    end

    def confirm
      @title = @type.to_s.capitalize + ' '
      @description = pr_params[:description]
    end

    def create
      @description = pr_params[:description]
      @title = pr_params[:title]
      result = client.open_pull_request_to(@branch, @title, @description)
      result.fmap do
        redirect_to(pull_request_ai_result_path(branch: @branch, type: @type))
      end.or do |error|
        @error_message = error.to_s.empty? ? 'Oops! Something went wrong.' : error.to_s
        render(:confirm)
      end
    end

    def result; end

    private

    def client
      @client ||= PullRequestAi::Client.new
    end

    def set_defaults
      @types = [['Feature', :feature], ['Release', :release], ['HotFix', :hotfix]]

      client.destination_branches.fmap do |branches|
        @error_message = nil
        @branches = branches
      end.or do |_|
        @error_message = "Your project doesn't have a repository configured."
        @branches = []
      end
    end

    def set_state
      @error_message = nil
      @branch = pr_params[:branch]
      @type = pr_params[:type]
    end

    def pr_params
      params.permit(:branch, :type, :title, :description)
    end
  end
end
