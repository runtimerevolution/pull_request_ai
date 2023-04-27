# frozen_string_literal: true

module PullRequestAi
  module OpenAi
    class Interpreter
      class << self
        include Dry::Monads[:result, :do]

        def chat!(feature_type, current_changes)
          response = PullRequestAi::OpenAi::Client.new.request_completions(
            content: build_chat_message(feature_type, current_changes)
          )

          build_response_object(response)
        rescue Net::ReadTimeout
          Error.failure(:connection_timeout)
        end

        private

        def build_chat_message(feature_type, current_changes)
          %(
            Write a #{feature_type} pull request description
            based on the following changes: #{current_changes}
          ).squish
        end

        def build_response_object(response)
          body = response.parsed_response

          if response.success?
            Success(body['choices'].first.dig('message', 'content'))
          else
            Error.failure(:failed_on_openai_api_endpoint, body.dig('error', 'message'))
          end
        end
      end
    end
  end
end
