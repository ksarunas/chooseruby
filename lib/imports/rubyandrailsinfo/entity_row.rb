# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    # One row of an entity table from the dump
    # Knows which of its columns belong to the entity and which describe its entry
    class EntityRow
      # Entity-specific columns kept per table; entry columns are nested separately
      ENTITY_FIELDS = {
        "books" => %w[id isbn year page amazon_url website_url free featured created_at updated_at],
        "courses" => %w[id free created_at updated_at],
        "newsletters" => %w[id created_at updated_at],
        "podcasts" => %w[id created_at updated_at],
        "communities" => %w[id platform_type members created_at updated_at],
        "youtubes" => %w[id created_at updated_at],
        "screencasts" => %w[id created_at updated_at],
        "lessons" => %w[id youtube_id created_at updated_at]
      }.freeze

      # Tables whose entry points at something other than the default website url
      ENTRY_URL_FIELDS = { "lessons" => "url" }.freeze
      DEFAULT_ENTRY_URL_FIELD = "website_url"

      def self.tables
        ENTITY_FIELDS.keys
      end

      def initialize(row, table)
        @row = row
        @table = table
      end

      # The entity fields with the entry fields nested under "entry", without nils
      def to_h
        entity_fields.merge("entry" => entry_fields.compact).compact
      end

      private

      def entity_fields
        @row.slice(*ENTITY_FIELDS.fetch(@table))
      end

      def entry_fields
        url_field = ENTRY_URL_FIELDS.fetch(@table, DEFAULT_ENTRY_URL_FIELD)

        { "title" => @row["title"], "content" => @row["content"], "slug" => @row["slug"],
          url_field => @row[url_field] }
      end
    end
  end
end
