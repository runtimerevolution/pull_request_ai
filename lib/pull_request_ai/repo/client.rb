# frozen_string_literal: true

module PullRequestAi
  module Repo
    class Client
      include Dry::Monads[:result, :do]

      attr_accessor :prompt

      def initialize(prompt: Prompt.new)
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
      rescue URI::InvalidComponentError
        Failure(:invalid_repository)
      end

      def remote_branches
        remote_name.bind do |name|
          branches = prompt.remote_branches
            .reject { !_1.strip.start_with?(name) }
            .map { _1.strip.sub(%r{\A#{name}/}, '') }
            .reject(&:empty?)
          Success(branches)
        end
      end

      def destination_branches
        current_branch.bind do |current|
          remote_branches.bind do |branches|
            Success(branches.reject { _1 == current || _1.start_with?('HEAD') })
          end
        end
      end

      def current_changes_to(base)
        current_branch.bind do |current|
          changes_between(base, current)
        end
      end

      def flatten_current_changes_to(base)
        current_changes_to(base).bind do |changes|
          Success(changes.inject(''.dup) { |result, file| result << file.trimmed_modified_lines })
        end
      end

      private

      def changes_between(branch1, branch2)
        if prompt.configured? == false
          Failure(:project_not_configured)
        else
          diff_output = prompt.configured? ? prompt.changes_between(branch1, branch2) : ''
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

          Success(changes)
        end
      end
    end
  end
end
