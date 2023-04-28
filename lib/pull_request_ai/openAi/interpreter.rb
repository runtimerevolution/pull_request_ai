# frozen_string_literal: true

module PullRequestAi
  module OpenAi
    class Interpreter
      def chat_message(feature_type, summary, current_changes)
        result = ''.dup
        unless summary.nil? || summary.strip.empty?
          result << "Given the following summary for the changes made:\n"
          result << "\"#{summary}\""
          result << "\n\n"
        end
        result << "Write a #{feature_type} pull request description based on the following changes:\n"
        result << current_changes
        puts result
        result.freeze
      end
    end
  end
end
