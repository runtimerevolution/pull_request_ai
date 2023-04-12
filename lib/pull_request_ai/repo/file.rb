# frozen_string_literal: true

module PullRequestAi
  module Repo
    class File
      attr_reader :name, :modified_lines

      def initialize(name, modified_lines)
        @name = name
        @modified_lines = modified_lines
      end

      def trimmed_modified_lines
        modified_lines.inject(name + "\n") do |result, line|
          result << line.sub(/([+\-])\s*/) { ::Regexp.last_match(1) } + "\n"
        end
      end
    end
  end
end
