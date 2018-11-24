# frozen_string_literal: true

require 'stringio'

require 'ephesus/text/adapters'
require 'ephesus/text/adapters/base_adapter'

module Ephesus::Text::Adapters
  # Handler class that tracks output and errors using StringIO instances.
  class StringAdapter < Ephesus::Text::Adapters::BaseAdapter
    def initialize(output_buffer = nil, error_buffer = nil)
      @output_buffer = output_buffer || StringIO.new
      @error_buffer  = error_buffer  || @output_buffer
    end

    attr_reader :error_buffer

    attr_reader :output_buffer

    def error(string)
      error_buffer.puts(string)
    end

    def error_string
      error_buffer.string
    end

    def output(string)
      output_buffer.puts(string)
    end

    def output_string
      output_buffer.string
    end
  end
end
