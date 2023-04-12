# frozen_string_literal: true

module PullRequestAi
  module Repo
    class Client
      include Dry::Monads[:result, :do]

      attr_accessor :prompt
      attr_accessor :github_api_endpoint
      attr_accessor :github_access_token

      def initialize(
        github_api_endpoint: nil,
        github_access_token: nil,
        prompt: Prompt.new
      )
        @github_api_endpoint = github_api_endpoint || PullRequestAi.github_api_endpoint
        @github_access_token = github_access_token || PullRequestAi.github_access_token
        @prompt = prompt
      end

      def current_branch
        prompt.configured? ? Success(prompt.current_branch) : Failure(:project_not_configured)
      end

      def remote_name
        prompt.configured? ? Success(prompt.remote_name) : Failure(:project_not_configured)
      end

      def repository_slug
        remote_name.bind do |name|
          url = prompt.remote_url(name)
          regex = %r{\A/?(?<slug>.*?)(?:\.git)?\Z}
          uri = GitCloneUrl.parse(url)
          match = regex.match(uri.path)
          match ? Success(match[:slug]) : Failure(:invalid_repository)
        end
      end

      def remote_branches
        remote_name.bind do |name|
          branches = prompt.remote_branches
            .map { _1.strip.sub(%r{\A#{name}/}, '') }
            .reject(&:empty?)
          Success(branches)
        end
      end

      def destination_branches
        current_branch.bind do |current|
          remote_branches.bind do |branches|
            Success(branches.reject { _1.end_with?(current.to_s) || _1.start_with?('HEAD') })
          end
        end
      end

      def current_changes_to(branch)
        current_branch.bind do |current|
          Success(prompt.changes_between(branch, current))
        end
      end

      def flatten_current_changes_to(branch)
        current_changes_to(branch).bind do |changes|
          Success(changes.inject('') { |result, file| result << file.trimmed_modified_lines })
        end
      end

      def changes_between(branch1, branch2)
        diff_output = prompt.changes_between(branch1, branch2)
        changes = []

        file_name = nil
        modified_lines = []
        diff_output.each_line do |line|
          line = line.chomp
          if line.start_with?('diff --git')
            if file_name && file_name.end_with?('.lock') == false
              changes << PullRequestAi::Repo::File.new(file_name, modified_lines)
            end
            file_name = line.split(' ')[-1].strip
            file_name = file_name.start_with?('b/') ? file_name[2..-1] : file_name
            modified_lines = []
          elsif line.start_with?('--- ') || line.start_with?('+++ ')
            next
          elsif line.start_with?('-') && line.strip != '-'
            modified_lines << line
          elsif line.start_with?('+') && line.strip != '+'
            modified_lines << line
          end
        end

        if file_name
          changes << PullRequestAi::Repo::File.new(file_name, modified_lines)
        end

        changes
      end

      def open_pull_request(to_branch, title, description)
        head = current_branch.or do |error|
          return Failure(error)
        end

        slug = repository_slug.or do |error|
          return Failure(error)
        end

        content = {
          title: title,
          body: description,
          head: head.value!,
          base: to_branch
        }.to_json

        request(slug.value!, content)
      end

      private

      def request(slug, content)
        response = HTTParty.send(
          :post,
          build_uri(slug),
          headers: headers,
          body: content
        )

        # https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#create-a-pull-request
        if response.code.to_i == 201
          Success(response.parsed_response)
        else
          errors = response.parsed_response['errors']&.map { |error| error['message'] }&.join(' ')
          errors.to_s.empty? ? Failure(:failed_on_github_api_endpoint) : Failure(errors)
        end
      end

      def build_uri(slug)
        "#{github_api_endpoint}/repos/#{slug}/pulls"
      end

      def headers
        {
          'Accept' => 'application/vnd.github+json',
          'Authorization' => "Bearer #{github_access_token}"
        }
      end
    end
  end
end
