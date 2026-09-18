# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    # A single scalar read from one of the rubyandrailsinfo YAML files
    # Knows how the dump spells timestamps and booleans
    class YamlValue
      TRUE_MARKERS = %w[t true].freeze

      def initialize(raw_value)
        @raw_value = raw_value
      end

      # The timestamp it denotes, or nil when it is blank or unparseable
      def to_time
        return nil if @raw_value.blank?

        Time.parse(@raw_value)
      rescue StandardError
        nil
      end

      # Whether it denotes a PostgreSQL or a literal true
      def to_bool
        TRUE_MARKERS.include?(@raw_value.to_s)
      end
    end
  end
end
