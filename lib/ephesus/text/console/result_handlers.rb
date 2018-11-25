# frozen_string_literal: true

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
        handler_block = lambda do |result|
          next unless result.data[:command_name] == command

          next if on == :success && result.failure?
          next if on == :failure && result.success?

          instance_exec(result, &block)
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
