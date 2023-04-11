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
        `git diff --patch #{branch1}..#{branch2}`.strip
      end

    end
  end
end