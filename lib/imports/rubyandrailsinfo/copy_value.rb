# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    # A single raw value taken from a line of a PostgreSQL COPY block
    # Knows the dump's NULL marker and its escape sequences
    class CopyValue
      NULL = '\N'

      def initialize(raw_value)
        @raw_value = raw_value
      end

      # nil for a PostgreSQL NULL, the unescaped string otherwise
      def to_ruby
        return nil if @raw_value == NULL
        return "" if @raw_value.empty?

        unescaped
      end

      private

      def unescaped
        @raw_value.gsub('\\t', "\t")
          .gsub('\\n', "\n")
          .gsub('\\r', "\r")
          .gsub("\\\\", "\\")
      end
    end
  end
end
