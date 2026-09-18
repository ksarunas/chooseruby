# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    # Imports every record of one YAML collection
    # Reports the failures as they happen and answers with the collection's tally
    class CollectionImport
      def initialize(import_class:, records:, id_mapper:)
        @import_class = import_class
        @records = records
        @id_mapper = id_mapper
        @tally = @import_class.tally
      end

      def run
        @records.each { |record| import(record) }
        puts summary_line
        @tally
      end

      private

      def import(record)
        @import_class.new(record, @id_mapper).import ? @tally.record_success : @tally.record_skip
      rescue StandardError => error
        puts "  ✗ Error importing #{@import_class.description(record)}: #{error.message}"
        @tally.record_error
      end

      def summary_line
        "✓ Imported #{@tally.success} #{@import_class.plural} (#{@tally.outcome})"
      end
    end
  end
end
