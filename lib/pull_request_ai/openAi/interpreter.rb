# frozen_string_literal: true

module PullRequestAi
  module OpenAi
    class Interpreter
      class << self
        include Dry::Monads[:result, :do]

        def chat!(feature_type, current_changes)
          PullRequestAi::OpenAi::Client.new.predicted_completions(
            content: build_chat_message(feature_type, current_changes)
          )
        end

        private

        def build_chat_message(feature_type, current_changes)
          %(
            Write a #{feature_type} pull request description
            based on the following changes: #{current_changes}
          ).squish
        end
      end
    end
  end
end
