# frozen_string_literal: true

require 'ephesus/text/utils'

module Ephesus::Text::Utils
  # Formatting utilities for processing Ephesus text output.
  module Format
    class << self
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
