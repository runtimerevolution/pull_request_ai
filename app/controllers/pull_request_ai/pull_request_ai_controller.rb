require_dependency 'pull_request_ai/application_controller'

module PullRequestAi
  class PullRequestAiController < ApplicationController
    before_action :set_defaults, only: [:index, :prepare]
    before_action :set_state, only: [:confirm, :create, :result]

    def index
    end

    def prepare
      branch = params[:branch]
      type = params[:type]
      
      if true
        redirect_to pull_request_ai_confirm_path(branch: branch, type: type)
      else
        @error_message = "Oops! Something went wrong."
        render :index
      end
    end

    def confirm
      @title = @type.to_s.capitalize + ' '
      @description = "This will be the result of the AI response."
    end

    def create
      @description = params[:description]
      @title = params[:title]
      result = repo_client.open_pull_request(@branch, @title, @description)
      result.or { |error|
        @error_message = error.to_s.empty? ? "Oops! Something went wrong." : error.to_s
        render :confirm
        return 
      }

      redirect_to pull_request_ai_result_path(branch: @branch, type: @type)
    end

    def result
    end

    private

    def repo_client
      @repo_client ||= PullRequestAi::Repo::Client.new
    end

    def set_defaults
      @types = [['Feature', :feature], ['Release', :release], ['HotFix', :hotfix]]

      repo_client.destination_branches.fmap { |branches|
        @error_message = nil
        @branches = branches
      }.or { |error|
        @error_message = "Your project doesn't have a repository configured."
        @branches = []
      }
    end

    def set_state
      @error_message = nil
      @branch = params[:branch]
      @type = params[:type]
    end
  end
end