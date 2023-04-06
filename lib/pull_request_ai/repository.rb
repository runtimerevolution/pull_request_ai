module PullRequestAi
  class Repository

    def configured?
      `git rev-parse --is-inside-work-tree > /dev/null 2>&1`
      $?.exitstatus == 0
    end
    
    def current_branch
      if configured?
        branch_name = `git rev-parse --abbrev-ref HEAD`.chomp
        branch_name == "HEAD" ? `git rev-parse --short HEAD`.chomp : branch_name
      else
        nil
      end
    end

    def main_head_branch
      remote_branches.find { |branch| branch.start_with?("origin/HEAD") }
    end

    def remote_branches
      configured? ? `git branch --remotes --no-color`.split("\n").map(&:strip) : []
    end

    def destination_branches
      if configured?
        current = current_branch
        remote_branches.reject { |branch| branch.end_with?("/#{current}") || branch.start_with?("origin/HEAD") }
      else
        []
      end
    end

    def current_changes_to(branch)
      configured? ? changes_between(branch, current_branch) : nil
    end

    def current_trimmed_changes_to(branch)
      if configured? 
        diff_changes = changes_between(branch, current_branch)
        diff_changes.inject("") { |result, changes|  result << changes.trimmed }
      end
    end

    def changes_between(branch1, branch2)
      diff_output = `git diff --patch #{branch1}..#{branch2}`.strip
      diff_changes = []

      current_file = nil
      removed = []
      added = []
      combined = []
      diff_output.each_line do |line|
        line = line.chomp
        if line.start_with?("diff --git")
          if current_file && current_file.end_with?(".lock") == false
            diff_changes << PullRequestAi::Changes.new(current_file, added, removed, combined)
          end
          current_file = line.split(" ")[-1].strip
          current_file = current_file.start_with?("b/") ? current_file[2..-1] : current_file
          removed = []
          added = []
          combined = []
        elsif line.start_with?("--- ") || line.start_with?("+++ ")
          next
        elsif line.start_with?("-") && line.strip != "-"
          removed << line
          combined << line
        elsif line.start_with?("+") && line.strip != "+"
          added << line
          combined << line
        end
      end

      if current_file
        diff_changes << PullRequestAi::Changes.new(current_file, added, removed, combined)
      end

      diff_changes
    end

    def open_pull_request(branch, description)

    end

  end
end