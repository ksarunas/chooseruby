# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    module Importers
      # Imports one authorings.yml record as the link between an Author and an Entry
      class AuthoringImport < RecordImport
        def self.plural
          "authorings"
        end

        def self.singular
          "authoring"
        end

        def self.description(_record)
          singular
        end

        def initialize(record, id_mapper)
          super
          @author = id_mapper.find_author(record["author_id"])
          @entry = id_mapper.find_entry(record["authorabble_type"], record["authorabble_id"])
        end

        # Links the author to the entry; false when either side was never imported
        def import
          return false unless @author && @entry

          EntriesAuthor.find_or_create_by!(entry: @entry, author: @author)
          true
        end
      end
    end
  end
end
