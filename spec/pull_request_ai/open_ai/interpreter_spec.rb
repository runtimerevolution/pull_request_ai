# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PullRequestAi::OpenAi::Interpreter) do
  let(:feature_type) { 'hotfix' }
  let(:current_changes) { 'width: 100%;' }

  # Invalid Request
  let(:error_body) do
    {
      'error' =>
            { 'message' => "You didn't provide an API key.", 'type' => 'invalid_request_error' }
    }
  end
  let(:invalid_http_response) do
    instance_double(
      HTTParty::Response,
      code: 401,
      parsed_response: error_body,
      success?: false
    )
  end

  # Valid Request
  let(:success_body) do
    { 'choices' => [{ 'message' => { 'role' => 'assistant', 'content' => 'your PR' } }] }
  end
  let(:valid_http_response) do
    instance_double(
      HTTParty::Response,
      code: 200,
      parsed_response: success_body,
      success?: true
    )
  end

  describe '#chat_message' do
    it 'builds the chat message correctly' do
      message = described_class.send(:build_chat_message, feature_type, current_changes)

      expect(message).to(include(feature_type))
      expect(message).to(include(current_changes))
    end
  end

  describe '#chat_request' do
    context 'with invalid request' do
      before { allow(HTTParty).to(receive(:post).and_return(invalid_http_response)) }

      it 'builds and returns an invalid response object' do
        translator = described_class.chat!(feature_type, current_changes)

        expect(translator).to(be_failure)
        expect(translator).not_to(be_success)
        expect(translator.failure.symbol).to(eq(:failed_on_openai_api_endpoint))
        expect(translator.failure.message).to(eq(error_body.dig('error', 'message')))
      end
    end

    context 'with valid request' do
      before { allow(HTTParty).to(receive(:post).and_return(valid_http_response)) }

      it 'builds and returns a valid response object' do
        translator = described_class.chat!(feature_type, current_changes)

        expect(translator).to(be_success)
        expect(translator).not_to(be_failure)
        expect(translator.success).to(eq(success_body['choices'].first.dig('message', 'content')))
      end
    end
  end
end
