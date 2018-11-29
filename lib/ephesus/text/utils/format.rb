# frozen_string_literal: true

require 'ephesus/text/utils'

module Ephesus::Text::Utils
  # Formatting utilities for processing Ephesus text output.
  module Format
    class << self
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
    end
  end
end
