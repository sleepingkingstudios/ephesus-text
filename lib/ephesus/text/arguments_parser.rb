# frozen_string_literal: true

require 'strscan'

require 'ephesus/text'

module Ephesus::Text
  # Specialized parser that processes command inputs into arguments and grouped
  # keywords.
  class ArgumentsParser
    def initialize(keywords: {})
      @expected_keywords = keywords
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def parse(input)
      scanner   = StringScanner.new(input)
      arguments = []
      keywords  = Hash.new { |hsh, key| hsh[key] = [] }
      buffer    = arguments

      while scanner.scan_until(scan_pattern)
        match = scanner.matched.strip

        buffer << scanner.pre_match.strip

        if expected_keywords.include?(match)
          buffer = keywords[match.tr(' ', '_').intern]
        end

        scanner.string = scanner.post_match
      end

      buffer << scanner.string.strip

      arguments << keywords unless keywords.empty?

      arguments
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    private

    attr_reader :expected_keywords

    def scan_pattern
      @scan_pattern ||= begin
        patterns =
          [*separators, *expected_keywords]
          .map { |str| " #{Regexp.escape(str)}" }

        Regexp.union(*patterns)
      end
    end

    def separators
      %w[and]
    end
  end
end
