module PullRequestAi
  module Repo
    class Prompt

      def configured?
        `git rev-parse --is-inside-work-tree > /dev/null 2>&1`
        $?.exitstatus == 0
      end

      def current_branch
        name = `git rev-parse --abbrev-ref HEAD`.chomp
        name == "HEAD" ? `git rev-parse --short HEAD`.chomp : name
      end

      def remote_name
        `git remote`.strip
      end

      def remote_url(name)
        `git config --get remote.#{name}.url`.strip
      end

      def remote_branches
        `git branch --remotes --no-color`.split("\n")
      end

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