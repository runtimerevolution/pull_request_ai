# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PullRequestAi::Repo::Api) do
  include Dry::Monads[:result]

  let(:api) { subject }
  let(:github_api_endpoint) { 'https://api.github.com' }
  let(:github_access_token) { 'someGithubAccessToken' }

  let(:configuration) do
    PullRequestAi.configure do |config|
      config.github_api_endpoint = github_api_endpoint
      config.github_access_token = github_access_token
    end
  end

  before do
    configuration
  end

  it 'can be initialized' do
    expect { described_class }.not_to(raise_error)
  end

  describe '::github_api_endpoint' do
    it 'initializes with the configured github_api_endpoint' do
      expect(api.github_api_endpoint).to(eq(github_api_endpoint))
    end

    it 'accepts github_api_endpoint as argument' do
      klass = described_class.new(github_api_endpoint: 'https://github.com')
      expect(klass.github_api_endpoint).to(eq('https://github.com'))
    end
  end

  describe '::github_access_token' do
    it 'initializes with the configured github_access_token' do
      expect(api.github_access_token).to(eq(github_access_token))
    end

    it 'accepts github_access_token as argument' do
      klass = described_class.new(github_access_token: 'Github Token')
      expect(klass.github_access_token).to(eq('Github Token'))
    end
  end

  describe '::retrieve_opened_pull_requests' do
    let(:fake_http_response) { instance_double(HTTParty::Response) }

    before do
      allow(HTTParty).to(receive(:send).and_return(fake_http_response))
      allow(fake_http_response).to(receive(:code)).and_return(200)
      allow(fake_http_response).to(receive(:parsed_response)).and_return({})
    end

    it 'sends user content to httparty request' do
      result = api.opened_pull_requests('repo/user', 'feature1')
      expect(HTTParty).to(have_received(:send).with(any_args))
      expect(result).to(be_success)
    end
  end

  describe '::update_pull_request' do
    let(:fake_http_response) { instance_double(HTTParty::Response) }

    before do
      allow(HTTParty).to(receive(:send).and_return(fake_http_response))
      allow(fake_http_response).to(receive(:code)).and_return(200)
      allow(fake_http_response).to(receive(:parsed_response)).and_return({})
    end

    it 'sends user content to httparty request' do
      result = api.update_pull_request('repo/user', 1, 'main', 'title', 'description')
      expect(HTTParty).to(have_received(:send).with(any_args))
      expect(result).to(be_success)
    end
  end

  describe '::create_pull_request' do
    let(:fake_http_response) { instance_double(HTTParty::Response) }

    before do
      allow(HTTParty).to(receive(:send).and_return(fake_http_response))
      allow(fake_http_response).to(receive(:code)).and_return(201)
      allow(fake_http_response).to(receive(:parsed_response)).and_return({})
    end

    it 'sends user content to httparty request' do
      result = api.open_pull_request('repo/user', 'feature1', 'main', 'title', 'description')
      expect(HTTParty).to(have_received(:send).with(any_args))
      expect(result).to(be_success)
    end
  end
end
