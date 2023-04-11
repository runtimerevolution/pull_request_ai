# frozen_string_literal: true

Rails.application.routes.draw do
  mount PullRequestAi::Engine => '/pull_request_ai'
end
