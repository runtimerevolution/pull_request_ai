require 'rails_helper'

RSpec.describe PullRequestAi::OpenAi::Client do
  let(:fake_http_response) { instance_double(HTTParty::Response) }

  let(:openai_api_key) { 'someApiKey'}
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
    expect { PullRequestAi::OpenAi::Client }.not_to raise_error
  end

  describe '::openai_api_key' do
    it 'should initialize with the configured openai_api_key' do
      expect(client.openai_api_key).to eq openai_api_key
    end

    it 'accepts openai_api_key as argument' do
      klass = described_class.new(openai_api_key: 'API Key')
      expect(klass.openai_api_key).to eq 'API Key'
    end
  end

  describe '::model' do
    it 'should initialize with the configured model' do
      expect(client.model).to eq(model)
    end

    it 'accepts model as argument' do
      klass = described_class.new(model: 'New Model')
      expect(klass.model).to eq 'New Model'
    end
  end

  describe '::temperature' do
    it 'should initialize with the configured temperature' do
      expect(client.temperature).to eq(temperature)
    end

    it 'accepts temperature as argument' do
      klass = described_class.new(temperature: 2)
      expect(klass.temperature).to eq 2
    end
  end

  describe '.request' do
    before do
      allow(HTTParty).to receive(:post).and_return(fake_http_response)
    end

    it 'sends user content to httparty request' do
      expect(HTTParty).to receive(:post).with(any_args)
      client.request(content: 'new chat')
    end
  end
end