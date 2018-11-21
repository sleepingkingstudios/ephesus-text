# frozen_string_literal: true

require 'forwardable'

require 'ephesus/text'
require 'ephesus/text/commands/no_matching_command_result'
require 'ephesus/text/parser'

module Ephesus::Text
  # IO manager class that wraps an Ephesus session and handles text input and
  # output.
  class Console
    extend Forwardable

    def initialize(session, parser: nil)
      @session = session
      @parser  = parser || build_parser(@session)
    end

    def_delegators :@session, :controller

    attr_reader :parser

    attr_reader :session

    def input(raw)
      parsed = parser.parse(raw)

      unless parsed[:match]
        return Ephesus::Text::Commands::NoMatchingCommandResult.new(parsed)
      end

      wrap_result(
        session.execute_command(parsed[:command], *parsed[:arguments]),
        parsed: parsed
      )
    end

    private

    def build_parser(session)
      Ephesus::Text::Parser.new(session)
    end

    def wrap_result(result, parsed:)
      result.data[:input]  = parsed[:input]
      result.data[:parsed] = parsed

      result
    end
  end
end
