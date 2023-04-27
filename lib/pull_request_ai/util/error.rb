# frozen_string_literal: true

module PullRequestAi
  class Error
    attr_reader :symbol, :message

    def initialize(symbol, message = nil)
      @symbol = symbol
      @message = message
    end

    def description
      error_desc = SYMBOL_DETAILS[symbol]
      if error_desc
        error_desc + (message ? " #{message}" : '')
      else
        message || symbol.to_s
      end
    end

    class << self
      def failure(symbol, message = nil)
        new_instance = new(symbol, message)
        Dry::Monads::Failure(new_instance)
      end
    end
  end
end
