# frozen_string_literal: true

require 'ephesus/core/command'
require 'ephesus/core/commands/built_in/command_data'
require 'ephesus/text/commands/built_in'

module Ephesus::Text::Commands::BuiltIn
  # Predefined command that returns general information to the user, or
  # information about a specific topic.
  class Help < Ephesus::Core::Command
    description 'Provides information about the requested command.'

    argument :command,
      description: 'The name of the command to query.',
      required:    false

    def initialize(available_commands)
      @available_commands = available_commands
    end

    attr_reader :available_commands

    private

    def data_command
      Ephesus::Core::Commands::BuiltIn::CommandData.new(available_commands)
    end

    def process(command = nil)
      return nil if command.nil?

      data_command.call(command)
    end
  end
end
