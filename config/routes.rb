# frozen_string_literal: true

PullRequestAi::Engine.routes.draw do
  root 'pull_request_ai#index'

  post 'prepare', to: 'pull_request_ai#prepare', as: 'pull_request_ai_prepare'
  get 'confirm', to: 'pull_request_ai#confirm', as: 'pull_request_ai_confirm'
  post 'create', to: 'pull_request_ai#create', as: 'pull_request_ai_create'
  get 'result', to: 'pull_request_ai#result', as: 'pull_request_ai_result'
end
