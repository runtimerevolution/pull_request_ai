# frozen_string_literal: true

module PullRequestAi
  module Repo
    class Prompt
      def configured?
        %x(git rev-parse --is-inside-work-tree > /dev/null 2>&1)
        $CHILD_STATUS.exitstatus == 0
      end

      def current_branch
        name = %x(git rev-parse --abbrev-ref HEAD).chomp
        name == 'HEAD' ? %x(git rev-parse --short HEAD).chomp : name
      end

      def remote_name
        %x(git remote).strip
      end

      def remote_url(name)
        %x(git config --get remote.#{name}.url).strip
      end

      def remote_branches
        %x(git branch --remotes --no-color).split("\n")
      end

      def changes_between(branch1, branch2)
        %x(git diff --patch #{branch1}..#{branch2}).strip
      end
    end
  end
end
