# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PullRequestAi::GitHub::Client) do
  include Dry::Monads[:result]

  let(:client) { subject }
  let(:api_endpoint) { 'https://api.github.com' }
  let(:access_token) { 'someGithubAccessToken' }

  let(:configuration) do
    PullRequestAi.configure do |config|
      config.github_api_endpoint = api_endpoint
      config.github_access_token = access_token
    end
  end

  before do
    configuration
  end

  it 'can be initialized' do
    expect { described_class }.not_to(raise_error)
  end

  describe '::api_endpoint' do
    it 'initializes with the configured api_endpoint' do
      expect(client.api_endpoint).to(eq(api_endpoint))
    end

    it 'accepts api_endpoint as argument' do
      klass = described_class.new(api_endpoint: 'https://github.com')
      expect(klass.api_endpoint).to(eq('https://github.com'))
    end
  end

  describe '::access_token' do
    it 'initializes with the configured access_token' do
      expect(client.access_token).to(eq(access_token))
    end

    it 'accepts access_token as argument' do
      klass = described_class.new(access_token: 'Access Token')
      expect(klass.access_token).to(eq('Access Token'))
    end
  end

  describe '::retrieve_opened_pull_requests' do
    let(:fake_http_response) { instance_double(HTTParty::Response) }

    before do
      allow(HTTParty).to(receive(:send).and_return(fake_http_response))
      allow(fake_http_response).to(receive(:parsed_response)).and_return({})
      allow(fake_http_response).to(receive(:success?)).and_return(true)
    end

    it 'sends user content to httparty request' do
      result = client.opened_pull_requests('repo/user', 'feature1', 'main')
      expect(HTTParty).to(have_received(:send).with(any_args))
      expect(result).to(be_success)
    end
  end

  describe '::update_pull_request' do
    let(:fake_http_response) { instance_double(HTTParty::Response) }

    before do
      allow(HTTParty).to(receive(:send).and_return(fake_http_response))
      allow(fake_http_response).to(receive(:parsed_response)).and_return({})
      allow(fake_http_response).to(receive(:success?)).and_return(true)
    end

    it 'sends user content to httparty request' do
      result = client.update_pull_request('repo/user', 1, 'main', 'title', 'description')
      expect(HTTParty).to(have_received(:send).with(any_args))
      expect(result).to(be_success)
    end
  end

  describe '::create_pull_request' do
    let(:fake_http_response) { instance_double(HTTParty::Response) }

    before do
      allow(HTTParty).to(receive(:send).and_return(fake_http_response))
      allow(fake_http_response).to(receive(:parsed_response)).and_return({})
      allow(fake_http_response).to(receive(:success?)).and_return(true)
    end

    it 'sends user content to httparty request' do
      result = client.open_pull_request('repo/user', 'feature1', 'main', 'title', 'description')
      expect(HTTParty).to(have_received(:send).with(any_args))
      expect(result).to(be_success)
    end
  end
end
