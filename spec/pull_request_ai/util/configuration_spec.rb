# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PullRequestAi::Util::Configuration) do
  it 'has an openai_api_key attribute' do
    config = described_class.new
    config.openai_api_key = 'someApiKey'
    expect(config.openai_api_key).to(eq('someApiKey'))
  end

  it 'has an github_access_token attribute' do
    config = described_class.new
    config.github_access_token = 'someGitHubAccessToken'
    expect(config.github_access_token).to(eq('someGitHubAccessToken'))
  end

  it 'has an bitbucket_app_password attribute' do
    config = described_class.new
    config.bitbucket_app_password = 'someBitbucketAppPassword'
    expect(config.bitbucket_app_password).to(eq('someBitbucketAppPassword'))
  end

  it 'has an bitbucket_username attribute' do
    config = described_class.new
    config.bitbucket_username = 'someUsername'
    expect(config.bitbucket_username).to(eq('someUsername'))
  end

  it 'has a model attribute' do
    config = described_class.new
    config.model = 'gpt-3.5-turbo'
    expect(config.model).to(eq('gpt-3.5-turbo'))
  end

  it 'has a temperature attribute' do
    config = described_class.new
    config.temperature = 0.8
    expect(config.temperature).to(eq(0.8))
  end

  it 'has a fixed openai_api_endpoint attribute' do
    config = described_class.new
    expect(config.openai_api_endpoint).to(eq('https://api.openai.com'))
  end

  it 'has a fixed github_api_endpoint attribute' do
    config = described_class.new
    expect(config.github_api_endpoint).to(eq('https://api.github.com'))
  end

  it 'has a fixed bitbucket_api_endpoint attribute' do
    config = described_class.new
    expect(config.bitbucket_api_endpoint).to(eq('https://api.bitbucket.org'))
  end

  it 'has a fixed api_version attribute' do
    config = described_class.new
    expect(config.api_version).to(eq('v1'))
  end
end
