# frozen_string_literal: true

module PullRequestAi
  module OpenAi
    # A client to communicate with the OpenAI API.
    class Client
      attr_accessor :openai_api_key
      attr_accessor :openai_api_endpoint
      attr_accessor :api_version
      attr_accessor :model
      attr_accessor :temperature
      attr_reader   :http_timeout

      ##
      # Initializes the client.
      def initialize(
        openai_api_key: nil,
        openai_api_endpoint: nil,
        api_version: nil,
        model: nil,
        temperature: nil
      )
        @openai_api_key = openai_api_key || PullRequestAi.openai_api_key
        @openai_api_endpoint = openai_api_endpoint || PullRequestAi.openai_api_endpoint
        @api_version = api_version || PullRequestAi.api_version
        @model = model || PullRequestAi.model
        @temperature = temperature || PullRequestAi.temperature
        @http_timeout = PullRequestAi.http_timeout
      end

      ##
      # Makes the completions request from the OpenAI API.
      # Given a prompt, the model will return one or more predicted completions.
      # https://platform.openai.com/docs/api-reference/chat
      def predicted_completions(content: '')
        url = build_url
        request(:post, url, body(content))
      end

      private

      def request(type, url, body)
        response = HTTParty.send(
          type, url, headers: headers, body: body, timeout: http_timeout
        )
        body = response.parsed_response

        if response.success?
          if body['choices'].nil? || body['choices'].empty?
            Dry::Monads::Success('')
          else
            Dry::Monads::Success(body['choices'].first.dig('message', 'content'))
          end
        else
          Error.failure(:failed_on_openai_api_endpoint, body.dig('error', 'message'))
        end
      rescue Net::ReadTimeout
        Error.failure(:connection_timeout)
      end

      def build_url
        "#{openai_api_endpoint}/#{api_version}/chat/completions"
      end

      def headers
        {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{openai_api_key}"
        }
      end

      def body(content)
        {
          model: model,
          messages: [{ role: :user, content: content }],
          temperature: temperature
        }.to_json
      end
    end
  end
end
