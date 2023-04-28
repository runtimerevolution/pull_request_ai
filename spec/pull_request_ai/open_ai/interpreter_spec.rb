# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PullRequestAi::OpenAi::Interpreter) do
  let(:interpreter) { described_class.new }

  let(:feature_type) { 'hotfix' }
  let(:summary) { 'size changes' }
  let(:current_changes) { 'width: 100%;' }

  it 'builds the chat message correctly with summary' do
    message = interpreter.send(:chat_message, feature_type, summary, current_changes)

    expect(message).to(include(feature_type))
    expect(message).to(include(summary))
    expect(message).to(include(current_changes))
  end

  it 'builds the chat message correctly with empty summary' do
    message = interpreter.send(:chat_message, feature_type, '   ', current_changes)

    expect(message).to(include(feature_type))
    expect(message).not_to(include('summary'))
    expect(message).to(include(current_changes))
  end

  it 'builds the chat message correctly without summary' do
    message = interpreter.send(:chat_message, feature_type, nil, current_changes)
    expect(message).to(include(feature_type))
    expect(message).to(include(current_changes))
  end
end
