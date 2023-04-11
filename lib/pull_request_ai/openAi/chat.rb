# frozen_string_literal: true

module PullRequestAi
  module OpenAi
    class Chat
      attr_accessor :description, :feature_type, :current_changes, :response

      ResponseObject = Struct.new(
        :chat_message, :status_code, :success, :body, :message, :error_type
      )

      def initialize(description, feature_type, current_changes)
        @description = description
        @feature_type = feature_type
        @current_changes = current_changes
      end

      def self.call(description, feature_type, current_changes)
        self.new(description, feature_type, current_changes).chat
      end

      def chat
        @response = PullRequestAi::OpenAi::Client.new.request(content: chat_message)

        build_response_object
      end

      private

      def chat_message
        @chat_message ||= %(
          Please write a pull request for this #{feature_type},
          Here's a short description: #{description},
          Those are all the relevant changes: #{current_changes}.
        ).squish
      end

      def build_response_object
        ResponseObject.new(
          chat_message,       # chat_message
          response.code,      # status_code
          response.success?,  # success
          response_body,      # body
          response.message,   # message
          response_error_type # error_type
        )
      end

      def response_body
        if response.success?
          response.parsed_response['choices'].first.dig('message', 'content')
        else
          response.parsed_response.dig('error', 'message')
        end
      end

      def response_error_type
        return if response.success?

        response.parsed_response.dig('error', 'type')
      end
    end
  end
end
