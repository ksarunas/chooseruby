# frozen_string_literal: true

# Admin screens for the book details behind a directory entry.
class Avo::Resources::Book < Avo::BaseResource
  self.title = :display_name
  self.includes = [ :entry ]
  self.description = "Create a Book first, then create an Entry and select this Book as the entryable"

  def fields
    field :id, as: :id, link_to_record: true

    publication_fields
    edition_fields
    entry_field
    timestamp_fields
  end

  private

  def publication_fields
    field :isbn, as: :text, help: "ISBN number (optional)"
    field :publisher, as: :text, help: "Publisher name"
    field :publication_year, as: :number, help: "Year of publication (1990-present)"
    field :page_count, as: :number, help: "Number of pages"
  end

  def edition_fields
    field :format, as: :select,
          enum: ::Book.formats,
          help: "Book format"
    field :purchase_url, as: :text, help: "Where to buy this book"
  end

  def entry_field
    field :entry, as: :has_one,
          help: "After creating this Book, go to Entries → New and select this Book"
  end

  def timestamp_fields
    field :created_at, as: :date_time, readonly: true, hide_on: [ :index ]
    field :updated_at, as: :date_time, readonly: true, hide_on: [ :index ]
  end
end
