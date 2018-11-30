# frozen_string_literal: true

require 'ephesus/text/utils'

module Ephesus::Text::Utils
  # Formatting utilities for processing Ephesus text output.
  module Format # rubocop:disable Metrics/ModuleLength
    class << self
      def format_command_help(properties)
        buffer = +"COMMAND - #{properties.fetch(:command_name)}"

        format_command_aliases(properties,          buffer: buffer)
        format_command_description(properties,      buffer: buffer)
        format_command_full_description(properties, buffer: buffer)
        format_command_arguments(properties,        buffer: buffer)
        format_command_keywords(properties,         buffer: buffer)
        format_command_examples(properties,         buffer: buffer)

        buffer << "\n"
      end

      def format_multiline_block(str, width: nil)
        return '' if str.nil? || str.empty?

        str =
          str
          .strip
          .gsub(/(\n\s*)/) { |match| match.count("\n") > 1 ? "\n\n" : ' ' }

        return str if width.nil?

        str.each_line.map.with_object(+'') do |line, buffer|
          buffer << word_wrap(line, width: width)
        end
      end

      def format_table(rows, gutter: ' ')
        return '' if rows.nil? || rows.empty?

        column_widths = calculate_column_widths(rows)

        rows.each.with_object(+'') do |cells, buffer|
          format_table_row(
            cells,
            buffer:        buffer,
            column_widths: column_widths,
            gutter:        gutter
          )
        end
      end

      private

      def calculate_column_widths(rows)
        cell_count = rows.map(&:size).max

        rows.each.with_object(Array.new(cell_count) { 0 }) do |row, ary|
          0.upto(cell_count - 1) do |index|
            size = row[index]&.size || 0

            ary[index] = size if size > ary[index]
          end
        end
      end

      def format_command_aliases(properties, buffer:)
        aliases = properties[:aliases]
        aliases = aliases.reject { |name| name == properties[:command_name] }

        return if aliases.empty?

        buffer << ' (also '
        buffer << aliases.map { |name| %("#{name}") }.join(', ')
        buffer << ')'
      end

      def format_command_argument(argument, buffer:)
        buffer << "\n  " << argument[:name].to_s.tr('_', ' ')
        buffer << (argument[:required] ? ' (required)' : ' (optional)')

        return if argument[:description].nil? || argument[:description].empty?

        buffer << ' - ' << argument[:description]
      end

      def format_command_arguments(properties, buffer:)
        return if properties[:arguments].empty?

        buffer << "\n\nARGUMENTS"

        properties[:arguments].each.with_index do |argument, index|
          buffer << "\n" unless index.zero?

          format_command_argument(argument, buffer: buffer)
        end
      end

      def format_command_description(properties, buffer:)
        description = properties[:description] ||
                      'There is no description for this command.'
        buffer << "\n  " << description
      end

      # rubocop:disable Metrics/AbcSize
      def format_command_example(example, buffer:)
        buffer << "\n\nEXAMPLE"

        unless example[:header].nil? || example[:header].empty?
          buffer << ' - ' << example[:header]
        end

        buffer << "\n  " << %("#{example[:command]}")

        format_multiline_block(example[:description], width: 76)
          .each_line { |line| buffer << "\n    " << line.strip }
      end
      # rubocop:enable Metrics/AbcSize

      def format_command_examples(properties, buffer:)
        properties[:examples].each do |example|
          format_command_example(example, buffer: buffer)
        end
      end

      def format_command_full_description(properties, buffer:)
        return unless properties[:full_description]

        buffer << "\n\nDESCRIPTION"

        format_multiline_block(properties[:full_description], width: 78)
          .each_line { |line| buffer << "\n  " << line.strip }
      end

      def format_command_keywords(properties, buffer:)
        return if properties[:keywords].empty?

        buffer << "\n\nKEYWORDS"

        properties[:keywords].each_value.with_index do |keyword, index|
          buffer << "\n" unless index.zero?

          format_command_argument(keyword, buffer: buffer)
        end
      end

      def format_table_row(cells, buffer:, column_widths:, gutter:)
        cells.each.with_index do |cell, index|
          buffer << gutter unless index.zero?
          buffer << cell.to_s
          buffer << ' ' * (column_widths[index] - (cell&.size || 0))
        end

        buffer << "\n"
      end

      def word_wrap(str, width:) # rubocop:disable Metrics/AbcSize
        buffer = +''
        line   = +''

        str.split(/\s+/).each do |word|
          next line << word if line.empty?

          next line << ' ' << word unless line.size + word.size + 1 > width

          buffer << line << "\n"
          line.clear
          line << word
        end

        buffer << line
      end
    end
  end
end
