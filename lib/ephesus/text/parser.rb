# frozen_string_literal: true

require 'forwardable'

require 'ephesus/text'
require 'ephesus/text/arguments_parser'

module Ephesus::Text
  # Parser class that takes a text input and finds the matching command and any
  # arguments or keywords.
  class Parser
    extend Forwardable

    def initialize(session)
      @session = session
    end

    def_delegators :@session,
      :controller,
      :state

    attr_reader :session

    def parse(input)
      @result = guard_input!(input)

      return @result if @result

      command, definition, rest = parse_command(input)

      return build_error_result(input) unless command

      arguments = parse_arguments(definition, rest)

      build_result(input, command: command, arguments: arguments)
    end

    private

    def aliased_commands(commands)
      keys = commands.each.with_object([]) do |(key, definition), ary|
        definition[:aliases].each { |str| ary << [str, key] }
      end

      keys
        .uniq { |str, _key| str }
        .sort { |(u, _u), (v, _v)| v <=> u } # Reverse sort by keys.
    end

    def build_result(input, command:, arguments:)
      {
        arguments: arguments,
        command:   command,
        input:     input,
        match:     true
      }
    end

    def build_error_result(input)
      {
        arguments: nil,
        command:   nil,
        input:     input,
        match:     false
      }
    end

    def guard_input!(input)
      return build_error_result(input) if input.nil?

      unless input.is_a?(String)
        raise ArgumentError, "input must be a String, but was #{input.inspect}"
      end

      return build_error_result(input) if input.empty?

      nil
    end

    def parse_arguments(definition, input)
      return [] if input.empty?

      keywords = definition[:keywords].keys.map { |key| key.to_s.tr('_', ' ') }
      parser   = Ephesus::Text::ArgumentsParser.new(keywords: keywords)

      parser.parse(input)
    end

    def parse_command(input)
      available_commands = controller.available_commands
      insensitive_input  = input.downcase
      command_aliases    = aliased_commands(available_commands)

      command_aliases.each do |matchable_key, key|
        next unless insensitive_input.start_with?(matchable_key)

        remainder = input[matchable_key.size..-1].strip

        return [key, available_commands[key], remainder]
      end

      nil
    end
  end
end
