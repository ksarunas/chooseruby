# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    # Main importer class to load YAML files and create database records
    # Uses idempotent strategies (find_or_create_by) and ID mapping for relationships
    class YamlImporter
      DIVIDER = ("=" * 60).freeze

      def initialize(yaml_dir:)
        @yaml_dir = yaml_dir
        @id_mapper = IdMapper.new
        @tallies = {}
      end

      def import_all
        puts "Importing YAML data from #{@yaml_dir}..."
        puts
        collection_imports.each { |import_class| import(import_class) }
        print_summary
      end

      private

      # The collections to import, in dependency order
      def collection_imports
        [ Importers::CategoryImport, Importers::AuthorImport,
          Importers::BookImport, Importers::CourseImport, Importers::NewsletterImport,
          Importers::PodcastImport, Importers::CommunityImport, Importers::YoutubeImport,
          Importers::ScreencastImport, Importers::LessonImport,
          Importers::AuthoringImport, Importers::TaggingImport ]
      end

      def import(import_class)
        @tallies[import_class.plural] = CollectionImport.new(
          import_class: import_class, records: load_yaml(import_class.filename), id_mapper: @id_mapper
        ).run
      end

      def load_yaml(filename)
        YAML.load_file(File.join(@yaml_dir, filename)) || []
      end

      def print_summary
        print_summary_header
        @tallies.each { |name, tally| puts tally.summary_lines(name) }
        puts
        puts "ID Mappings: #{@id_mapper.stats.inspect}"
      end

      def print_summary_header
        puts
        puts [ DIVIDER, "Import Summary", DIVIDER ]
      end
    end
  end
end
