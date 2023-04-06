module PullRequestAi
  module Repo
    class File
      attr_reader :name, :modified_lines

      def initialize(name, modified_lines)
        @name = name
        @modified_lines = modified_lines
      end

      def trimmed_modified_lines
        modified_lines.inject(name + "\n") { |result, line|
          result << line.sub(/([+\-])\s*/) { $1 } + "\n"
        }
      end

    end
  end
end