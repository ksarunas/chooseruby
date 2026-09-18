# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    module Importers
      # Imports one youtubes.yml record as a Video with its Entry
      class YoutubeImport < VideoRecordImport
        def self.plural
          "youtubes"
        end

        def self.singular
          "youtube"
        end
      end
    end
  end
end
