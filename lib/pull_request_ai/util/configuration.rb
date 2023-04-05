module PullRequestAi
  module Util
    class Configuration
      attr_accessor :openai_api_key

      def openai_api_key=(value)
        @openai_api_key = value
      end
    end
  end
end