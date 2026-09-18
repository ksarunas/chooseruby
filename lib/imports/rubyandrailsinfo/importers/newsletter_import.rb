# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    module Importers
      # Imports one newsletters.yml record as a Newsletter named after its Entry
      class NewsletterImport < EntryRecordImport
        def self.plural
          "newsletters"
        end

        def self.singular
          "newsletter"
        end

        private

        def entryable
          Newsletter.create! do |newsletter|
            newsletter.assign_attributes(name: entry_data["title"],
                                         created_at: time("created_at"), updated_at: time("updated_at"))
          end
        end
      end
    end
  end
end
