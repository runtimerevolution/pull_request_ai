# frozen_string_literal: true

require 'rails_helper'

describe Rack::Attack do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  before do
    allow_any_instance_of(
      PullRequestAi::PullRequestAiController
    ).to(receive(:prepare).and_return({}))

    described_class.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  describe 'throttle excessive POST requests to api confirmation' do
    let(:limit) { 5 }

    context 'when number of requests is lower than the limit' do
      it 'does not change the request status' do
        limit.times do
          post '/pull_request_ai/prepare',
            { pull_request_ai: { branch: 'test' } },
            'REMOTE_ADDR' => '1.2.3.9'
          expect(last_response.status).not_to(eq(429))
        end
      end
    end

    context 'when number of requests is higher than the limit' do
      it 'changes the request status to 429' do
        (limit * 2).times do |i|
          post '/pull_request_ai/prepare',
            { pull_request_ai: { branch: 'test' } },
            'REMOTE_ADDR' => '1.2.3.9'
          expect(last_response.status).to(eq(429)) if i > limit
        end
      end
    end
  end
end
