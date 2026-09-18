# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    module Importers
      # Imports one tags.yml record as a Category, identified by its slug
      class CategoryImport < RecordImport
        def self.plural
          "categories"
        end

        def self.singular
          "category"
        end

        def self.filename
          "tags.yml"
        end

        def self.tally
          ImportTally.new
        end

        def import
          id_mapper.register_category(record["id"], category)
          true
        end

        private

        def category
          Category.find_or_create_by!(slug: record["slug"]) do |new_category|
            new_category.assign_attributes(name: record["title"],
                                           created_at: time("created_at"), updated_at: time("updated_at"))
          end
        end
      end
    end
  end
end
