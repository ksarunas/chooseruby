# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    module Importers
      # Imports one taggings.yml record as the link between a Category and an Entry
      # The first category an entry receives becomes its primary one
      class TaggingImport < RecordImport
        def self.plural
          "taggings"
        end

        def self.singular
          "tagging"
        end

        def self.description(_record)
          singular
        end

        def initialize(record, id_mapper)
          super
          @category = id_mapper.find_category(record["tag_id"])
          @entry = id_mapper.find_entry(record["taggable_type"], record["taggable_id"])
        end

        # Categorises the entry; false when either side was never imported
        def import
          return false unless @category && @entry

          categorise
          true
        end

        private

        def categorise
          CategoriesEntry.find_or_create_by!(entry: @entry, category: @category) do |categories_entry|
            categories_entry.assign_attributes(is_primary: first_category?, is_featured: false)
          end
        end

        def first_category?
          CategoriesEntry.where(entry: @entry).count == 0
        end
      end
    end
  end
end
