# frozen_string_literal: true

PullRequestAi::Engine.routes.draw do
  scope :rrtools do
    scope path: 'pull_request_ai' do
      root 'pull_request_ai#new'

      post 'prepare', to: 'pull_request_ai#prepare', as: 'pull_request_ai_prepare'
      post 'create', to: 'pull_request_ai#create', as: 'pull_request_ai_create'
      post 'update', to: 'pull_request_ai#update', as: 'pull_request_ai_update'
    end
  end
end
