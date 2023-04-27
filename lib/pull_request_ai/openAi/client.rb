# frozen_string_literal: true

module PullRequestAi
  module OpenAi
    # A client to access the OpenAI API.
    class Client
      attr_accessor :openai_api_key
      attr_accessor :openai_api_endpoint
      attr_accessor :api_version
      attr_accessor :model
      attr_accessor :temperature
      attr_reader   :http_timeout

      ##
      # Initializes the Client
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
      # Makes a request to the OpenAI API
      # Authentication information is automatically added
      def request(content: '')
        HTTParty.post(
          build_uri,
          headers: headers,
          body: body(content),
          timeout: http_timeout
        )
      end

      private

      def build_uri
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
