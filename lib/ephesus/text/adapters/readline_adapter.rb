# frozen_string_literal: true

require 'ephesus/text/adapters'
require 'ephesus/text/adapters/base_adapter'

module Ephesus::Text::Adapters
  # IO adapter using terminal input and output via the Readline library.
  class ReadlineAdapter < Ephesus::Text::Adapters::BaseAdapter
    def error(string)
      warn string
    end

    def output(string)
      puts string
    end

    def start
      while (str = Readline.readline('> ', true))
        str = str&.strip

        break if exit_strings.include?(str)

        input(str)
      end
    end

    private

    def exit_strings
      %w[exit]
    end
  end
end
