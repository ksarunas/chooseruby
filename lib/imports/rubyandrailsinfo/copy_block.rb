# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    # A single COPY block of a PostgreSQL dump
    # Knows its column names and turns its tab-delimited lines into rows
    class CopyBlock
      HEADER = /COPY "public"\."[^"]+" \(([^)]+)\) FROM stdin;/
      COLUMN_NAME = /"([^"]+)"/
      TERMINATOR = '\.'

      def initialize(text)
        @lines = text.split("\n")
        @column_names = text.match(HEADER)[1].scan(COLUMN_NAME).flatten
      end

      # Rows as hashes mapping column name to value, dropping malformed lines
      def rows
        data_lines.filter_map { |line| row_from(line) }
      end

      private

      def row_from(line)
        values = line.split("\t").map { |raw_value| CopyValue.new(raw_value).to_ruby }
        return nil unless values.length == @column_names.length

        @column_names.zip(values).to_h
      end

      def data_lines
        @lines[(header_index + 1)...terminator_index]
      end

      def header_index
        @lines.find_index { |line| line.match?(HEADER) }
      end

      def terminator_index
        @lines.find_index { |line| line == TERMINATOR }
      end
    end
  end
end
