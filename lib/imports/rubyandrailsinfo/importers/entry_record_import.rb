# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    module Importers
      # Imports a YAML record that carries an entity together with its Entry
      # Subclasses build the entity the entry points at
      class EntryRecordImport < RecordImport
        # The polymorphic type the old database used for this collection
        def self.entry_type
          singular.capitalize
        end

        def initialize(record, id_mapper)
          super
          @entry_data = record["entry"]
        end

        # Creates the entity and its entry; false when the record has no entry title
        def import
          return false unless importable?

          id_mapper.register_entry(self.class.entry_type, record["id"], create_entry)
          true
        end

        private

        attr_reader :entry_data

        def importable?
          @entry_data && @entry_data["title"].present?
        end

        def create_entry
          Entry.find_or_create_by!(entryable: entryable) do |entry|
            entry.assign_attributes(entry_attributes)
          end
        end

        def entry_attributes
          { title: entry_data["title"], description: entry_data["content"], url: entry_url,
            slug: entry_data["slug"], status: :approved, published: true, tags: [],
            created_at: time("created_at"), updated_at: time("updated_at") }
            .merge(audience_attributes)
        end

        def audience_attributes
          { experience_level: :intermediate, featured_at: featured_at }
        end

        def featured_at
          bool("featured") ? time("created_at") : nil
        end

        # The url the entity advertises, or a placeholder built from the entry slug
        def entry_url
          advertised_url.presence || "https://example.com/#{entry_data["slug"]}"
        end

        def advertised_url
          entry_data["website_url"] || record["website_url"] || record["amazon_url"]
        end
      end
    end
  end
end
