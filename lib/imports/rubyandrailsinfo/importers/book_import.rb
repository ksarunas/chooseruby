# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    module Importers
      # Imports one books.yml record as a Book with its Entry
      # Books are identified by ISBN, falling back to the slug of an entry already imported
      class BookImport < EntryRecordImport
        def self.plural
          "books"
        end

        def self.singular
          "book"
        end

        private

        def entryable
          isbn = record["isbn"]
          return book_with_isbn(isbn) if isbn.present?

          already_imported_book || new_book
        end

        def book_with_isbn(isbn)
          Book.find_or_create_by!(isbn: isbn) { |book| book.assign_attributes(book_attributes) }
        end

        def already_imported_book
          Entry.find_by(slug: entry_data["slug"], entryable_type: "Book")&.entryable
        end

        def new_book
          Book.create! { |book| book.assign_attributes(book_attributes) }
        end

        def book_attributes
          { publication_year: record["year"]&.to_i, page_count: record["page"]&.to_i,
            purchase_url: record["amazon_url"] || record["website_url"], format: :both,
            created_at: time("created_at"), updated_at: time("updated_at") }
        end
      end
    end
  end
end
