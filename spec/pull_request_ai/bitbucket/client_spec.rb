# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PullRequestAi::Bitbucket::Client) do
  include Dry::Monads[:result]

  let(:client) { subject }
  let(:api_endpoint) { 'https://api.bitbucket.org' }
  let(:app_password) { 'someBitbucketAppPassword' }
  let(:username) { 'someUsername' }

  let(:configuration) do
    PullRequestAi.configure do |config|
      config.bitbucket_api_endpoint = api_endpoint
      config.bitbucket_app_password = app_password
      config.bitbucket_username = username
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
      klass = described_class.new(api_endpoint: 'https://bitbucket.com')
      expect(klass.api_endpoint).to(eq('https://bitbucket.com'))
    end
  end

  describe '::app_password' do
    it 'initializes with the configured app_password' do
      expect(client.app_password).to(eq(app_password))
    end

    it 'accepts app_password as argument' do
      klass = described_class.new(app_password: 'App Password')
      expect(klass.app_password).to(eq('App Password'))
    end
  end

  describe '::username' do
    it 'initializes with the configured username' do
      expect(client.username).to(eq(username))
    end

    it 'accepts username as argument' do
      klass = described_class.new(username: 'aUsername')
      expect(klass.username).to(eq('aUsername'))
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
