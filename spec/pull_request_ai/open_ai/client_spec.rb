# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PullRequestAi::OpenAi::Client) do
  let(:fake_http_response) { instance_double(HTTParty::Response) }

  let(:openai_api_key) { 'someApiKey' }
  let(:model) { 'someModel' }
  let(:temperature) { 'someTemperature' }

  let(:client) { described_class.new }
  let(:configuration) do
    PullRequestAi.configure do |config|
      config.openai_api_key = openai_api_key
      config.model = model
      config.temperature = temperature
    end
  end

  before do
    configuration
  end

  it 'can be initialized' do
    expect { described_class }.not_to(raise_error)
  end

  describe '::openai_api_key' do
    it 'initializes with the configured openai_api_key' do
      expect(client.openai_api_key).to(eq(openai_api_key))
    end

    it 'accepts openai_api_key as argument' do
      klass = described_class.new(openai_api_key: 'API Key')
      expect(klass.openai_api_key).to(eq('API Key'))
    end
  end

  describe '::model' do
    it 'initializes with the configured model' do
      expect(client.model).to(eq(model))
    end

    it 'accepts model as argument' do
      klass = described_class.new(model: 'New Model')
      expect(klass.model).to(eq('New Model'))
    end
  end

  describe '::temperature' do
    it 'initializes with the configured temperature' do
      expect(client.temperature).to(eq(temperature))
    end

    it 'accepts temperature as argument' do
      klass = described_class.new(temperature: 2)
      expect(klass.temperature).to(eq(2))
    end
  end

  describe '.request' do
    context 'with invalid request' do
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

      before { allow(HTTParty).to(receive(:post).and_return(invalid_http_response)) }
      
      it 'builds and returns an invalid response object' do
          response = client.predicted_completions(content: 'new chat')

          expect(HTTParty).to(have_received(:post).with(any_args))
          expect(response).to(be_failure)
          expect(response).not_to(be_success)
          expect(response.failure.symbol).to(eq(:failed_on_openai_api_endpoint))
          expect(response.failure.message).to(eq(error_body.dig('error', 'message')))
        end
    end

    context 'with valid request' do
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

      before { allow(HTTParty).to(receive(:post).and_return(valid_http_response)) }

      it 'builds and returns a valid response object' do
        response = client.predicted_completions(content: 'new chat')

        expect(HTTParty).to(have_received(:post).with(any_args))
        expect(response).to(be_success)
        expect(response).not_to(be_failure)
        expect(response.success).to(eq(success_body['choices'].first.dig('message', 'content')))
      end
    end
  end
end
