# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    # Counts how the records of one imported collection fared
    # and phrases those counts for the import report
    class ImportTally
      attr_reader :success, :errors, :skipped

      def initialize
        @success = 0
        @errors = 0
        @skipped = 0
      end

      def record_success
        @success += 1
      end

      def record_error
        @errors += 1
      end

      def record_skip
        @skipped += 1
      end

      # How the collection's own line ends
      def outcome
        "#{@errors} errors"
      end

      # The lines this collection contributes to the closing summary
      def summary_lines(name)
        [ "#{name.capitalize}: #{@success} success", *details ]
      end

      private

      def details
        errors_detail
      end

      def errors_detail
        @errors.positive? ? [ "  Errors: #{@errors}" ] : []
      end
    end
  end
end
