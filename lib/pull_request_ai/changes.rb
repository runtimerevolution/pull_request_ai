module PullRequestAi
  class Changes
    attr_reader :file_name, :added, :removed, :combined

    def initialize(file_name, added, removed, combined)
      @file_name = file_name
      @added = added
      @removed = removed
      @combined = combined
    end

    def trimmed
      result = file_name + "\n"
      combined.each { |line| 
        result << line.sub(/([+\-])\s*/) { $1 } + "\n"
      }
      result
    end

  end
end