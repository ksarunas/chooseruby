# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    module Importers
      # Imports a YAML record whose entity is a Video named after its Entry
      class VideoRecordImport < EntryRecordImport
        private

        def entryable
          Video.create! do |video|
            video.assign_attributes(name: entry_data["title"],
                                    created_at: time("created_at"), updated_at: time("updated_at"))
          end
        end
      end
    end
  end
end
