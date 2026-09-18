# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    module Importers
      # Imports a single YAML record into the database
      # Subclasses name their collection and know how to persist one of its records
      class RecordImport
        # The tally a collection of these records is counted with
        def self.tally
          SkippingImportTally.new
        end

        def self.filename
          "#{plural}.yml"
        end

        # How a record is named when its import fails
        def self.description(record)
          "#{singular} #{record["id"]}"
        end

        def initialize(record, id_mapper)
          @record = record
          @id_mapper = id_mapper
        end

        private

        attr_reader :record, :id_mapper

        def time(key)
          YamlValue.new(record[key]).to_time
        end

        def bool(key)
          YamlValue.new(record[key]).to_bool
        end
      end
    end
  end
end
