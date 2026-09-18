# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    module Importers
      # Imports one courses.yml record as a Course with its Entry
      class CourseImport < EntryRecordImport
        def self.plural
          "courses"
        end

        def self.singular
          "course"
        end

        private

        def entryable
          Course.create! do |course|
            course.assign_attributes(is_free: bool("free"),
                                     created_at: time("created_at"), updated_at: time("updated_at"))
          end
        end
      end
    end
  end
end
