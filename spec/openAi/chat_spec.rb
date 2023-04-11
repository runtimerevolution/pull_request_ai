require 'rails_helper'

RSpec.describe PullRequestAi::OpenAi::Chat do
  let(:description) { 'fix navbar size' }
  let(:feature_type) { 'hotfix' }
  let(:current_changes) { 'width: 100%;' }

  # Invalid Request
  let(:error_body) do
    { 'error' =>
      { 'message' => "You didn't provide an API key.", 'type' => 'invalid_request_error' }
    }
  end
  let(:invalid_http_response) do
    double(
      'HTTParty::Response',
      code: 401,
      parsed_response: error_body,
      success?: false,
      message: 'Unauthorized'
    )
  end

  # Valid Request
  let(:success_body) do
    { 'choices' => [{ 'message' => { 'role' => 'assistant', 'content' => 'your PR' }}]}
  end
  let(:valid_http_response) do
    double(
      'HTTParty::Response',
      code: 200,
      parsed_response: success_body,
      success?: true,
      message: 'OK'
    )
  end

  describe '#chat_message' do
    before { allow(HTTParty).to receive(:post).and_return(valid_http_response) }

    it 'builds the chat message correctly' do
      translator = described_class.(description, feature_type, current_changes)

      expect(translator.chat_message).to include(description)
      expect(translator.chat_message).to include(feature_type)
      expect(translator.chat_message).to include(current_changes)
    end
  end

  describe '#chat_request' do
    context 'with invalid request' do
      before { allow(HTTParty).to receive(:post).and_return(invalid_http_response) }

      it 'builds and returns an invalid response object' do
        translator = described_class.(description, feature_type, current_changes)

        expect(translator.status_code).to eq invalid_http_response.code
        expect(translator.success).to eq invalid_http_response.success?
        expect(translator.body).to eq error_body.dig('error', 'message')
        expect(translator.message).to eq invalid_http_response.message
        expect(translator.error_type).to eq error_body.dig('error', 'type')
      end
    end

    context 'with valid request' do
      before { allow(HTTParty).to receive(:post).and_return(valid_http_response) }

      it 'builds and returns a valid response object' do
        translator = described_class.(description, feature_type, current_changes)

        expect(translator.status_code).to eq valid_http_response.code
        expect(translator.success).to eq valid_http_response.success?
        expect(translator.body).to eq success_body['choices'].first.dig('message', 'content')
        expect(translator.message).to eq valid_http_response.message
        expect(translator.error_type).to be_nil
      end
    end
  end
end
