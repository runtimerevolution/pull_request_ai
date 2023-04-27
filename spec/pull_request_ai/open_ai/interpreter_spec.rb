# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PullRequestAi::OpenAi::Interpreter) do
  let(:interpreter) { described_class.new }

  let(:feature_type) { 'hotfix' }
  let(:current_changes) { 'width: 100%;' }

  it 'builds the chat message correctly' do
    message = interpreter.send(:chat_message, feature_type, current_changes)

    expect(message).to(include(feature_type))
    expect(message).to(include(current_changes))
  end
end
