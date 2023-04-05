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
        head = main_head_branch
        remote_branches.reject { |branch| branch.end_with?("/#{current}") || branch == head }
      else
        []
      end
    end

  end
end