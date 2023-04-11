# frozen_string_literal: true

module PullRequestAi
  module OpenAi
    class Chat
      include Dry::Monads[:result, :do]

      attr_accessor :feature_type, :current_changes

      def initialize(feature_type, current_changes)
        @feature_type = feature_type
        @current_changes = current_changes
      end

      def chat!
        response = PullRequestAi::OpenAi::Client.new.request(content: chat_message)

        build_response_object(response)
      end

      private

      def chat_message
        @chat_message ||= %(
          Write a #{feature_type} pull request description
          based on the following changes: #{current_changes}
        ).squish
      end

      def build_response_object(response)
        body = response.parsed_response

        if response.success?
          Success(body['choices'].first.dig('message', 'content'))
        else
          Failure(body.dig('error', 'message'))
        end
      end
    end
  end
end
