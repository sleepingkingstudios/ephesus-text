# frozen_string_literal: true

require 'ephesus/core/commands/result'
require 'ephesus/text/commands'

module Ephesus::Text::Commands
  # Predefined result, to be returned when the parser is unable to match the
  # input to an available command.
  class NoMatchingCommandResult < Ephesus::Core::Commands::Result
    NO_MATCHING_COMMAND_ERROR = 'ephesus.text.errors.no_matching_command'

    def initialize(parsed, **keywords)
      super(nil, **keywords)

      data[:input]  = parsed[:input]
      data[:parsed] = parsed

      errors.add(NO_MATCHING_COMMAND_ERROR, input: parsed[:input])
    end
  end
end
