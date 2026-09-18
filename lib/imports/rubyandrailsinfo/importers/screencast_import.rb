# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    module Importers
      # Imports one screencasts.yml record as a Video with its Entry
      class ScreencastImport < VideoRecordImport
        def self.plural
          "screencasts"
        end

        def self.singular
          "screencast"
        end
      end
    end
  end
end
