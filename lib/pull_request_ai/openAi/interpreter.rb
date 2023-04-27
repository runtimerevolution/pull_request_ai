# frozen_string_literal: true

module PullRequestAi
  module OpenAi
    class Interpreter
      def chat_message(feature_type, current_changes)
        %(
          Write a #{feature_type} pull request description
          based on the following changes: #{current_changes}
        ).squish
      end
    end
  end
end
