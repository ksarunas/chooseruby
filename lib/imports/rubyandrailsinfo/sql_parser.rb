# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    # Parses PostgreSQL SQL dump files in COPY format
    # Extracts table data from tab-delimited COPY statements
    class SqlParser
      def initialize(sql_file_path)
        @content = File.read(sql_file_path)
      end

      # Extract data for a specific table
      # Returns array of hashes: [{column_name: value, ...}, ...]
      def extract_table(table_name)
        copy_block = find_copy_block(table_name)
        return [] unless copy_block

        copy_block.rows
      end

      private

      # Find the COPY block for a specific table
      def find_copy_block(table_name)
        # Match: COPY "public"."table_name" (...) FROM stdin;
        # Capture everything until the terminator \.
        pattern = /COPY "public"\."#{Regexp.escape(table_name)}" \([^)]+\) FROM stdin;.*?^\\\.$/m
        match = @content.match(pattern)
        CopyBlock.new(match.to_s) if match
      end
    end
  end
end
