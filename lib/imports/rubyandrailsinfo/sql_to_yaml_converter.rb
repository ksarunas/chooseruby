# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    # Converts a PostgreSQL dump into the YAML files the importer reads
    # Writes one file per table, nesting entry data for the entity tables
    class SqlToYamlConverter
      # Tables written out as they come, before and after the entity tables
      LOOKUP_TABLES = %w[tags authors].freeze
      JOIN_TABLES = %w[authorings taggings].freeze

      def initialize(sql_file:, output_dir:)
        @output_dir = output_dir
        @parser = SqlParser.new(sql_file)
      end

      def convert_all
        FileUtils.mkdir_p(@output_dir)
        announce_start
        convert_tables
        puts
        puts "All conversions complete! YAML files created in #{@output_dir}"
      end

      private

      def announce_start
        puts "Converting SQL data to YAML files..."
        puts "Output directory: #{@output_dir}"
        puts
      end

      def convert_tables
        convert_plain_tables(LOOKUP_TABLES)
        convert_entity_tables
        convert_plain_tables(JOIN_TABLES)
      end

      def convert_plain_tables(tables)
        tables.each { |table_name| convert_plain_table(table_name) }
      end

      def convert_entity_tables
        EntityRow.tables.each { |table_name| convert_entity_table(table_name) }
      end

      def convert_plain_table(table_name)
        rows = @parser.extract_table(table_name)

        write_yaml(table_name, rows.map(&:compact))
      end

      def convert_entity_table(table_name)
        rows = @parser.extract_table(table_name)

        write_yaml(table_name, rows.map { |row| EntityRow.new(row, table_name).to_h })
      end

      def write_yaml(table_name, data)
        filename = "#{table_name}.yml"
        File.write(File.join(@output_dir, filename), data.to_yaml)
        puts "✓ Converted #{table_name}: #{data.count} records → #{filename}"
      end
    end
  end
end
