# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    class SqlToYamlConverter
      # Entity-specific columns kept per table; entry columns are nested separately
      ENTITY_FIELDS = {
        "books" => %w[id isbn year page amazon_url website_url free featured created_at updated_at],
        "courses" => %w[id free created_at updated_at],
        "newsletters" => %w[id created_at updated_at],
        "podcasts" => %w[id created_at updated_at],
        "communities" => %w[id platform_type members created_at updated_at],
        "youtubes" => %w[id created_at updated_at],
        "screencasts" => %w[id created_at updated_at],
        "lessons" => %w[id youtube_id created_at updated_at]
      }.freeze

      def initialize(sql_file:, output_dir:)
        @sql_file = sql_file
        @output_dir = output_dir
        @parser = SqlParser.new(sql_file)
      end

      def convert_all
        # Create output directory
        FileUtils.mkdir_p(@output_dir)

        puts "Converting SQL data to YAML files..."
        puts "Output directory: #{@output_dir}"
        puts

        # Simple tables
        convert_simple_table("tags", "tags.yml")
        convert_simple_table("authors", "authors.yml")

        # Entity tables with entry data
        convert_entity_with_entry("books", "books.yml")
        convert_entity_with_entry("courses", "courses.yml")
        convert_entity_with_entry("newsletters", "newsletters.yml")
        convert_entity_with_entry("podcasts", "podcasts.yml")
        convert_entity_with_entry("communities", "communities.yml")

        # Video-related tables (separate, not combined)
        convert_entity_with_entry("youtubes", "youtubes.yml")
        convert_entity_with_entry("screencasts", "screencasts.yml")
        convert_entity_with_entry("lessons", "lessons.yml")

        # Join tables
        convert_join_table("authorings", "authorings.yml")
        convert_join_table("taggings", "taggings.yml")

        puts
        puts "All conversions complete! YAML files created in #{@output_dir}"
      end

      private

      def convert_simple_table(table_name, yaml_filename)
        # Extract data from SQL
        data = @parser.extract_table(table_name)

        # Remove nil values from each record
        clean_data = data.map { |record| record.compact }

        # Write to YAML
        write_yaml(clean_data, yaml_filename)

        puts "✓ Converted #{table_name}: #{data.count} records → #{yaml_filename}"
      end

      def convert_entity_with_entry(entity_table, yaml_filename)
        # Extract entity data
        entity_data = @parser.extract_table(entity_table)

        # For each entity, nest the entry-related fields
        transformed_data = entity_data.map do |record|
          # Separate entity fields from entry fields
          entity_fields = extract_entity_fields(record, entity_table)
          entry_fields = extract_entry_fields(record, entity_table)

          # Combine with entry nested, remove nils
          entity_fields.merge("entry" => entry_fields.compact).compact
        end

        write_yaml(transformed_data, yaml_filename)

        puts "✓ Converted #{entity_table}: #{entity_data.count} records → #{yaml_filename}"
      end

      def convert_join_table(table_name, yaml_filename)
        # Same as simple table for join tables
        convert_simple_table(table_name, yaml_filename)
      end

      def extract_entity_fields(record, entity_table)
        record.slice(*ENTITY_FIELDS.fetch(entity_table))
      end

      def extract_entry_fields(record, entity_table)
        # Common entry fields across all entity types
        base_fields = {
          "title" => record["title"],
          "content" => record["content"],
          "slug" => record["slug"]
        }

        # Add appropriate URL field based on entity type
        if entity_table == "lessons"
          # Lessons use 'url' field instead of 'website_url'
          base_fields.merge("url" => record["url"])
        else
          # All others use 'website_url'
          base_fields.merge("website_url" => record["website_url"])
        end
      end

      def write_yaml(data, filename)
        file_path = File.join(@output_dir, filename)
        File.write(file_path, data.to_yaml)
      end
    end
  end
end
