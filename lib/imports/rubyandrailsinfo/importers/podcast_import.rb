# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    module Importers
      # Imports one podcasts.yml record as a Podcast with its Entry
      class PodcastImport < EntryRecordImport
        def self.plural
          "podcasts"
        end

        def self.singular
          "podcast"
        end

        private

        def entryable
          Podcast.create! do |podcast|
            podcast.assign_attributes(created_at: time("created_at"), updated_at: time("updated_at"))
          end
        end
      end
    end
  end
end
