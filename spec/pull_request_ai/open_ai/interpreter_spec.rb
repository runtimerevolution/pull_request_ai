# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PullRequestAi::OpenAi::Interpreter) do
  let(:feature_type) { 'hotfix' }
  let(:current_changes) { 'width: 100%;' }

  it 'builds the chat message correctly' do
    message = described_class.send(:build_chat_message, feature_type, current_changes)

    expect(message).to(include(feature_type))
    expect(message).to(include(current_changes))
  end
end
