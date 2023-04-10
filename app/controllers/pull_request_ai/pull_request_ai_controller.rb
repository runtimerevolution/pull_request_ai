require_dependency 'pull_request_ai/application_controller'

module PullRequestAi
  class PullRequestAiController < ApplicationController
    before_action :set_defaults, only: [:index, :prepare]
    before_action :set_state, only: [:confirm, :create, :result]

    def index
    end

    def prepare
      _branch = params[:branch]
      _type = params[:type]
      
      if true
        redirect_to pull_request_ai_confirm_path(branch: _branch, type: _type)
      else
        @error_message = "Oops! Something went wrong."
        render :index
      end
    end

    def confirm
      binding.pry
      @description = "This will be the result of the AI response."
    end

    def create
      @description = params[:description]
      if true
        redirect_to pull_request_ai_result_path(branch: @branch, type: @type)
      else
        @error_message = "Oops! Something went wrong."
        render :confirm
      end
    end

    def result
    end

    private

    def set_defaults
      @error_message = nil
      @branches = ["main", "random", "other"]
      @types = [['Feature', :feature], ['Hot-fix', :hotfix], ['Release', :release]]
    end

    def set_state
      @error_message = nil
      @branch = params[:branch]
      @type = params[:type]
    end
  end
end