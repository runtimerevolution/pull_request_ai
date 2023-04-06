module PullRequestAi
  module Repo
    class Reader
      include Dry::Monads[:result, :do]

      def configured?
        `git rev-parse --is-inside-work-tree > /dev/null 2>&1`
        $?.exitstatus == 0
      end

      def current_branch
        if configured?
          name = `git rev-parse --abbrev-ref HEAD`.chomp
          Success(name == "HEAD" ? `git rev-parse --short HEAD`.chomp : name)
        else
          Failure(:project_not_configured)
        end
      end

      def remote_branches
        if configured?
          branches = `git branch --remotes --no-color`.split("\n").map(&:strip)
          Success(branches)
        else
          Failure(:project_not_configured)
        end
      end

      def destination_branches
        current_branch.bind { |current|
          remote_branches.bind { |branches|
            Success(branches.reject { |branch| branch.end_with?("/#{current}") || branch.start_with?("origin/HEAD") })
          }
        }
      end

      def current_changes_to(branch)
        current_branch.bind { |current|
          Success(changes_between(branch, current))
        }
      end

      def flatten_current_changes_to(branch)
        current_changes_to(branch).bind { |changes|
          Success(changes.inject("") { |result, file|  result << file.trimmed_modified_lines })
        }
      end
  
      private 

      def changes_between(branch1, branch2)
        diff_output = `git diff --patch #{branch1}..#{branch2}`.strip
        changes = []
  
        file_name = nil
        modified_lines = []
        diff_output.each_line do |line|
          line = line.chomp
          if line.start_with?("diff --git")
            if file_name && file_name.end_with?(".lock") == false
              changes << PullRequestAi::Repo::File.new(file_name, modified_lines)
            end
            file_name = line.split(" ")[-1].strip
            file_name = file_name.start_with?("b/") ? file_name[2..-1] : file_name
            modified_lines = []
          elsif line.start_with?("--- ") || line.start_with?("+++ ")
            next
          elsif line.start_with?("-") && line.strip != "-"
            modified_lines << line
          elsif line.start_with?("+") && line.strip != "+"
            modified_lines << line
          end
        end
  
        if file_name
          changes << PullRequestAi::Repo::File.new(file_name, modified_lines)
        end
  
        changes
      end

    end
  end
end