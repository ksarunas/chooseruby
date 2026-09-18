# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    module Importers
      # Imports one lessons.yml record as a Video with its Entry
      # A lesson addresses any audience and points at a YouTube video, often by bare id
      class LessonImport < VideoRecordImport
        YOUTUBE_VIDEO_ID = /^[a-zA-Z0-9_-]{11}$/

        def self.plural
          "lessons"
        end

        def self.singular
          "lesson"
        end

        private

        def audience_attributes
          { experience_level: :all_levels }
        end

        def entry_url
          video_reference = entry_data["url"]
          return entry_data["website_url"] if video_reference.blank?
          return "https://www.youtube.com/watch?v=#{video_reference}" if video_reference.match?(YOUTUBE_VIDEO_ID)

          video_reference
        end
      end
    end
  end
end
