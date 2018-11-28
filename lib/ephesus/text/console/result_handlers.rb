# frozen_string_literal: true

require 'ephesus/core/command'
require 'ephesus/text/console'

module Ephesus::Text
  # Included module for handling input results, including by command or by error
  # type. Can be included directly in a console, or included in an intermediate
  # module which can be included in consoles.
  module Console::ResultHandlers
    def self.included(other)
      super

      other.extend(ClassMethods)
    end

    # Class methods when including ResultHandlers in a console or module.
    module ClassMethods
      def handle_command(command, on: nil, &block)
        handler_block =
          if command.is_a?(Class)
            command_class_handler(command.name, block: block, on: on)
          elsif command_class_name?(command)
            command_class_handler(command, block: block, on: on)
          else
            command_name_handler(command, block: block, on: on)
          end

        result_handlers << handler_block
      end

      def handle_error(error_type = nil, &block)
        handler_block =
          if error_type
            specific_error_handler(block, error_type)
          else
            generic_error_handler(block)
          end

        result_handlers << handler_block
      end

      def handle_result(&block)
        result_handlers << block
      end

      private

      def command_class_handler(command_class, block:, on:)
        lambda do |result|
          next unless result.data[:command_class] == command_class

          next if on == :success && result.failure?
          next if on == :failure && result.success?

          instance_exec(result, &block)
        end
      end

      def command_class_name?(command)
        command.is_a?(String) && command =~ /::/
      end

      def command_name_handler(command_name, block:, on:)
        lambda do |result|
          next unless result.data[:command_name] == command_name

          next if on == :success && result.failure?
          next if on == :failure && result.success?

          instance_exec(result, &block)
        end
      end

      def generic_error_handler(block)
        lambda do |result|
          next unless result.failure?

          instance_exec(result, &block)
        end
      end

      def result_handlers
        @result_handlers ||= []
      end

      def specific_error_handler(block, error_type)
        lambda do |result|
          next unless result.failure?

          matching_error =
            result.errors.find do |error|
              error[:type] == error_type
            end

          instance_exec(result, matching_error, &block) if matching_error
        end
      end
    end

    def input(string)
      super.tap do |result|
        each_result_handler { |handler| instance_exec(result, &handler) }
      end
    end

    private

    def each_result_handler
      self
        .class
        .ancestors
        .select { |mod| mod < Ephesus::Text::Console::ResultHandlers }
        .each do |mod|
          mod.send(:result_handlers).each { |handler| yield handler }
        end
    end
  end
end
