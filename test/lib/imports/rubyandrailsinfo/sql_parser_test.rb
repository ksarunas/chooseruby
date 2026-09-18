# frozen_string_literal: true

require "test_helper"

module Imports
  module Rubyandrailsinfo
    class SqlParserTest < ActiveSupport::TestCase
      SQL_DUMP = <<~SQL
        -- PostgreSQL database dump

        COPY "public"."authors" ("id", "name", "website_url", "created_at") FROM stdin;
        1\tMatz\t\\N\t2022-06-19 09:25:40.28688
        2\tTab\\tSeparated\\nLines\\rHere\\\\Backslash\t\thttps://example.com
        3\tMissing columns
        \\.

        COPY "public"."tags" ("id", "title") FROM stdin;
        \\.
      SQL

      setup do
        @sql_file = Tempfile.new([ "dump", ".sql" ])
        @sql_file.write(SQL_DUMP)
        @sql_file.flush
        @parser = SqlParser.new(@sql_file.path)
      end

      teardown { @sql_file.close! }

      test "extracts rows as hashes keyed by column name" do
        rows = @parser.extract_table("authors")

        assert_equal 2, rows.size
        assert_equal(
          { "id" => "1", "name" => "Matz", "website_url" => nil, "created_at" => "2022-06-19 09:25:40.28688" },
          rows.first
        )
      end

      test "unescapes PostgreSQL COPY escapes and keeps empty strings" do
        row = @parser.extract_table("authors").last

        assert_equal "Tab\tSeparated\nLines\rHere\\Backslash", row["name"]
        assert_equal "", row["website_url"]
        assert_equal "https://example.com", row["created_at"]
      end

      test "drops lines whose value count does not match the columns" do
        ids = @parser.extract_table("authors").map { |row| row["id"] }

        assert_equal %w[1 2], ids
      end

      test "returns an empty array for a table with no rows" do
        assert_equal [], @parser.extract_table("tags")
      end

      test "returns an empty array for a table absent from the dump" do
        assert_equal [], @parser.extract_table("missing")
      end
    end
  end
end
