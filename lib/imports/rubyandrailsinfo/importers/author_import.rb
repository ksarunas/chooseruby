# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    module Importers
      # Imports one authors.yml record as an approved Author, identified by its slug
      class AuthorImport < RecordImport
        def self.plural
          "authors"
        end

        def self.singular
          "author"
        end

        def self.tally
          ImportTally.new
        end

        def import
          id_mapper.register_author(record["id"], author)
          true
        end

        private

        def author
          Author.find_or_create_by!(slug: record["slug"]) do |new_author|
            new_author.assign_attributes(author_attributes)
          end
        end

        def author_attributes
          { name: record["name"], twitter_url: record["twitter_url"], github_url: record["github_url"],
            website_url: record["website_url"], status: :approved,
            created_at: time("created_at"), updated_at: time("updated_at") }
        end
      end
    end
  end
end
