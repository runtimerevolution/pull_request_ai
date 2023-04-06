module PullRequestAi
  class Changes
    attr_reader :file_name, :lines

    def initialize(file_name, lines)
      @file_name = file_name
      @lines = lines
    end

    def trimmed
      lines.inject(file_name + "\n") { |result, line|
        result << line.sub(/([+\-])\s*/) { $1 } + "\n"
      }
    end

  end
end