require 'rails_helper'

RSpec.describe PullRequestAi::Repo::Client do
  include Dry::Monads[:result]

  let(:github_api_endpoint) { 'https://api.github.com' }
  let(:github_access_token) { 'someGithubAccessToken'}

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
    expect { PullRequestAi::Repo::Client }.not_to raise_error
  end

  describe '::github_api_endpoint' do
    it 'should initialize with the configured github_api_endpoint' do
      expect(subject.github_api_endpoint).to eq github_api_endpoint
    end

    it 'accepts github_api_endpoint as argument' do
      klass = described_class.new(github_api_endpoint: 'https://github.com')
      expect(klass.github_api_endpoint).to eq 'https://github.com'
    end
  end

  describe '::github_access_token' do
    it 'should initialize with the configured github_access_token' do
      expect(subject.github_access_token).to eq github_access_token
    end

    it 'accepts github_access_token as argument' do
      klass = described_class.new(github_access_token: 'Github Token')
      expect(klass.github_access_token).to eq 'Github Token'
    end
  end

  describe '::prompt' do
    let (:prompt) { instance_double(PullRequestAi::Repo::Prompt) }

    it 'should initialize with a prompt object' do
      expect(subject.prompt).to be_truthy
    end

    it 'should accepts a prompt object as argument' do
      klass = described_class.new(prompt: prompt)
      expect(klass.prompt).to eq prompt
    end

    describe 'not configured' do
      before do
        allow(prompt).to receive(:configured?).and_return(false)
      end

      it 'should return failure when getting current branch' do
        client = described_class.new(prompt: prompt)
        expect(client.current_branch.failure).to eq(:project_not_configured)
      end

      it 'should return failure when getting remote name' do
        client = described_class.new(prompt: prompt)
        expect(client.remote_name.failure).to eq(:project_not_configured)
      end

      it 'should return failure when getting the repository slug' do
        client = described_class.new(prompt: prompt)
        expect(client.repository_slug.failure).to eq(:project_not_configured)
      end

      it 'should return failure when getting the remote branches' do
        client = described_class.new(prompt: prompt)
        expect(client.remote_branches.failure).to eq(:project_not_configured)
      end

      it 'should return failure when getting the available destination branches' do
        client = described_class.new(prompt: prompt)
        expect(client.destination_branches.failure).to eq(:project_not_configured)
      end

      it 'should return failure when getting the current changes to another branch' do
        client = described_class.new(prompt: prompt)
        expect(client.current_changes_to('main').failure).to eq(:project_not_configured)
      end

      it 'should return failure when getting the flatten current changes to another branch' do
        client = described_class.new(prompt: prompt)
        expect(client.flatten_current_changes_to('main').failure).to eq(:project_not_configured)
      end

      it 'should return failure when trying to open a pull request' do
        client = described_class.new(prompt: prompt)
        expect(client.open_pull_request('main', 'title', 'description').failure).to eq(:project_not_configured)
      end
    end

    describe 'configured' do
      let(:changes) {
        """
diff --git a/Gemfile.lock b/Gemfile.lock
index da9fca1..ed2168e 100644
--- a/Gemfile.lock
+++ b/Gemfile.lock
@@ -3,9 +3,8 @@ PATH
    specs:
      pull_request_ai (0.1.0)
        dry-monads
+      git_clone_url
        httparty
-      octokit
-      rack-attack
        rails (>= 7.0.4.3)
  
diff --git a/app/controllers/pull_request_ai/pull_request_ai_controller.rb b/app/controllers/pull_request_ai/pull_request_ai_controller.rb
index 52e12f6..4279e70 100644
--- a/app/controllers/pull_request_ai/pull_request_ai_controller.rb
+++ b/app/controllers/pull_request_ai/pull_request_ai_controller.rb
@@ -3,17 +3,15 @@ require_dependency 'pull_request_ai/application_controller'
  module PullRequestAi
    class PullRequestAiController < ApplicationController
      before_action :set_defaults, only: [:index, :prepare]
-    before_action :set_state, only: [:confirm, :create, :result]
+    before_action :set_state, only: [:prepare, :confirm, :create, :result]
  
      def index
      end
  
      def prepare
-      _branch = params[:branch]
-      _type = params[:type]
        
        if true
-        redirect_to pull_request_ai_confirm_path(branch: _branch, type: _type)
+        redirect_to pull_request_ai_confirm_path(branch: @branch, type: @type)
        """
      }

      before do
        allow(prompt).to receive(:configured?).and_return(true)
        allow(prompt).to receive(:current_branch).and_return('feature1')
        allow(prompt).to receive(:remote_name).and_return('origin')
        allow(prompt).to receive(:remote_url).with('origin').and_return('https://github.com/runtimerevolution/pull_request_ai.git')
        allow(prompt).to receive(:remote_branches).and_return(["origin/main", "main_local", "origin/feature1", "origin/feature2", "other"])
        allow(prompt).to receive(:changes_between).with('main', 'feature1').and_return(changes)
      end

      it 'should return the branch name' do
        client = described_class.new(prompt: prompt)
        expect(client.current_branch.value!).to eq 'feature1'
      end

      it 'should return the remote name' do
        client = described_class.new(prompt: prompt)
        expect(client.remote_name.value!).to eq 'origin'
      end

      it 'should return the repository slug from a https url' do
        client = described_class.new(prompt: prompt)
        expect(client.repository_slug.value!).to eq 'runtimerevolution/pull_request_ai'
      end

      it 'should return the repository slug from a ssh url' do
        allow(prompt).to receive(:remote_url).with('origin').and_return('git@github.com:runtimerevolution/pull_request_ai.git')
        client = described_class.new(prompt: prompt)
        expect(client.repository_slug.value!).to eq 'runtimerevolution/pull_request_ai'
      end

      it 'should return failure from an invalid url' do
        allow(prompt).to receive(:remote_url).with('origin').and_return('runtimerevolution/pull_request_ai.git')
        client = described_class.new(prompt: prompt)
        expect(client.repository_slug.failure).to eq(:invalid_repository)
      end

      it 'should return a list of text branches only from the remote and ignore local branches' do
        client = described_class.new(prompt: prompt)
        expect(client.remote_branches.value!).to eq(["main", "feature1", "feature2"])
      end

      it 'should return a list of text branches only from the remote ignoring local branches and excluding current branch' do
        client = described_class.new(prompt: prompt)
        expect(client.destination_branches.value!).to eq(["main", "feature2"])
      end

      it 'should return a list of File objects with the line changes' do
        client = described_class.new(prompt: prompt)
        result = client.current_changes_to('main').value!
        # It should ignore the Gemfile.lock and from this example only one File was modiefied.
        expect(result.count).to eq(1)
        expect(result.first.name).to eq("app/controllers/pull_request_ai/pull_request_ai_controller.rb")
        expect(result.first.modified_lines.count).to eq(6)
        expect(result.first.modified_lines.first).to eq("-    before_action :set_state, only: [:confirm, :create, :result]")
      end

      it 'should return a text of the line changed if configured' do
        client = described_class.new(prompt: prompt)
        result = client.flatten_current_changes_to('main').value!
        
        # It should ignore the Gemfile.lock.
        # It should start with the file name.
        # No space between the + or - and the actual change.
        expect(result).to eq("""app/controllers/pull_request_ai/pull_request_ai_controller.rb
-before_action :set_state, only: [:confirm, :create, :result]
+before_action :set_state, only: [:prepare, :confirm, :create, :result]
-_branch = params[:branch]
-_type = params[:type]
-redirect_to pull_request_ai_confirm_path(branch: _branch, type: _type)
+redirect_to pull_request_ai_confirm_path(branch: @branch, type: @type)
""")
      end

      describe 'request' do
        let(:fake_http_response) { instance_double(HTTParty::Response) }

        before do
          allow(HTTParty).to receive(:send).and_return(fake_http_response)
          allow(fake_http_response).to receive(:code).and_return(201)
          allow(fake_http_response).to receive(:parsed_response).and_return(
            double('response', status: 201, body: {}, headers: {})
          )
        end

        it 'should perform a request to the GitHub API' do
          client = described_class.new(prompt: prompt)
          expect(HTTParty).to receive(:send).with(:post, any_args)
          result = client.open_pull_request("main", "title", "description")
          expect(result).to be_success
        end
      end
    end
  end
end