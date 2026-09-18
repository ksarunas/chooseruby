# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    # The tally of a collection whose records can also be passed over
    class SkippingImportTally < ImportTally
      def outcome
        "#{errors} errors, #{skipped} skipped"
      end

      private

      def details
        errors_detail + skipped_detail
      end

      def skipped_detail
        count = skipped

        count.positive? ? [ "  Skipped: #{count}" ] : []
      end
    end
  end
end
