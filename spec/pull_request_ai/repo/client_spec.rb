# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PullRequestAi::Repo::Client) do
  include Dry::Monads[:result]

  let(:client) { subject }
  let(:prompt) { instance_double(PullRequestAi::Repo::Prompt) }

  it 'can be initialized' do
    expect { described_class }.not_to(raise_error)
  end

  describe '::prompt' do
    it 'initializes with a prompt object' do
      expect(client.prompt).to(be_truthy)
    end

    it 'accepts as argument a prompt object' do
      klass = described_class.new(prompt: prompt)
      expect(klass.prompt).to(eq(prompt))
    end
  end

  describe '::not_configured' do
    before do
      allow(prompt).to(receive(:configured?).and_return(false))
    end

    it 'fails when getting current branch' do
      client = described_class.new(prompt: prompt)
      expect(client.current_branch.failure).to(eq(:project_not_configured))
    end

    it 'fails when getting remote name' do
      client = described_class.new(prompt: prompt)
      expect(client.remote_name.failure).to(eq(:project_not_configured))
    end

    it 'fails when getting the repository slug' do
      client = described_class.new(prompt: prompt)
      expect(client.repository_slug.failure).to(eq(:project_not_configured))
    end

    it 'fails when getting the remote branches' do
      client = described_class.new(prompt: prompt)
      expect(client.remote_branches.failure).to(eq(:project_not_configured))
    end

    it 'fails when getting the available destination branches' do
      client = described_class.new(prompt: prompt)
      expect(client.destination_branches.failure).to(eq(:project_not_configured))
    end

    it 'fails when getting the current changes to another branch' do
      client = described_class.new(prompt: prompt)
      expect(client.current_changes_to('main').failure).to(eq(:project_not_configured))
    end

    it 'fails when getting the flatten current changes to another branch' do
      client = described_class.new(prompt: prompt)
      expect(client.flatten_current_changes_to('main').failure).to(eq(:project_not_configured))
    end
  end

  describe '::configured' do
    let(:changes) do
      '
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

diff --git a/app/controllers/engine/pull_request_ai_controller.rb b/app/controllers/engine/pull_request_ai_controller.rb
index 52e12f6..4279e70 100644
--- a/app/controllers/pull_request_ai/pull_request_ai_controller.rb
+++ b/app/controllers/pull_request_ai/pull_request_ai_controller.rb
@@ -3,17 +3,15 @@ require_dependency \'pull_request_ai/application_controller\'
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
      '
    end

    before do
      allow(prompt).to(receive(:configured?).and_return(true))
      allow(prompt).to(receive(:current_branch).and_return('feature1'))
      allow(prompt).to(receive(:remote_name).and_return('origin'))
      allow(prompt).to(receive(:remote_url).with('origin').and_return('https://github.com/runtimerevolution/pull_request_ai.git'))
      allow(prompt).to(receive(:remote_branches)
        .and_return(['origin/main', 'main_local', 'origin/feature1', 'origin/feature2', 'other']))
      allow(prompt).to(receive(:changes_between).with('main', 'feature1').and_return(changes))
    end

    it 'returns the branch name' do
      client = described_class.new(prompt: prompt)
      expect(client.current_branch.value!).to(eq('feature1'))
    end

    it 'returns the remote name' do
      client = described_class.new(prompt: prompt)
      expect(client.remote_name.value!).to(eq('origin'))
    end

    it 'returns the repository slug from a https url' do
      client = described_class.new(prompt: prompt)
      expect(client.repository_slug.value!).to(eq('runtimerevolution/pull_request_ai'))
    end

    it 'returns the repository slug from a ssh url' do
      allow(prompt).to(receive(:remote_url)
        .with('origin')
        .and_return('git@github.com:runtimerevolution/pull_request_ai.git'))
      client = described_class.new(prompt: prompt)
      expect(client.repository_slug.value!).to(eq('runtimerevolution/pull_request_ai'))
    end

    it 'fails from an invalid url' do
      allow(prompt).to(receive(:remote_url).with('origin').and_return('runtimerevolution/pull_request_ai.git'))
      client = described_class.new(prompt: prompt)
      expect(client.repository_slug.failure).to(eq(:invalid_repository))
    end

    it 'returns a list of text branches only from the remote and ignore local branches' do
      client = described_class.new(prompt: prompt)
      expect(client.remote_branches.value!).to(eq(['main', 'feature1', 'feature2']))
    end

    it 'returns a list of text branches only from the remote ignoring local branches and excluding current branch' do
      client = described_class.new(prompt: prompt)
      expect(client.destination_branches.value!).to(eq(['main', 'feature2']))
    end

    it 'ignores the Gemfile.lock file' do
      client = described_class.new(prompt: prompt)
      result = client.current_changes_to('main').value!
      expect(result.count).to(eq(1))
      expect(result.first.name).not_to(be('Gemfile.lock'))
    end

    it 'returns a list of File objects with the line changes' do
      client = described_class.new(prompt: prompt)
      result = client.current_changes_to('main').value!
      expect(result.first.modified_lines.count).to(eq(6))
    end

    it 'returns a text of the line changed' do
      client = described_class.new(prompt: prompt)
      result = client.flatten_current_changes_to('main').value!
      expect(result).not_to(be_empty)
    end

    it 'returns a text of the line changed without the Gemfile.lock' do
      client = described_class.new(prompt: prompt)
      result = client.flatten_current_changes_to('main').value!
      expect(result).not_to(include('Gemfile.lock'))
    end

    it 'returns a text of the line changed for pull_request_ai_controller.rb' do
      client = described_class.new(prompt: prompt)
      result = client.flatten_current_changes_to('main').value!
      expect(result).to(start_with('app/controllers/engine/pull_request_ai_controller.rb'))
    end
  end
end
