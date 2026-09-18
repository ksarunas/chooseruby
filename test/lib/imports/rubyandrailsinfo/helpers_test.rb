# frozen_string_literal: true

require "test_helper"

module Imports
  module Rubyandrailsinfo
    class HelpersTest < ActiveSupport::TestCase
      setup { Helpers.reset_lookups! }
      teardown { Helpers.reset_lookups! }

      test "registers and finds entries by old polymorphic type and id" do
        entry = Entry.new(title: "Registered")

        Helpers.register_entry("Book", 7, entry)

        assert_same entry, Helpers.find_entry("Book", 7)
        assert_nil Helpers.find_entry("Book", 8)
        assert_nil Helpers.find_entry("Course", 7)
      end

      test "registers and finds authors by old id regardless of id type" do
        author = Author.new(name: "Matz")

        Helpers.register_author(3, author)

        assert_same author, Helpers.find_author("3")
        assert_nil Helpers.find_author(4)
      end

      test "registers and finds categories by old tag id regardless of id type" do
        category = Category.new(name: "Testing")

        Helpers.register_category("12", category)

        assert_same category, Helpers.find_category(12)
        assert_nil Helpers.find_category(13)
      end

      test "reset_lookups! clears every registry" do
        Helpers.register_entry("Book", 1, Entry.new)
        Helpers.register_author(1, Author.new)
        Helpers.register_category(1, Category.new)

        Helpers.reset_lookups!

        assert_nil Helpers.find_entry("Book", 1)
        assert_nil Helpers.find_author(1)
        assert_nil Helpers.find_category(1)
      end

      test "parse_time returns nil for nil, PostgreSQL NULL and empty strings" do
        assert_nil Helpers.parse_time(nil)
        assert_nil Helpers.parse_time('\N')
        assert_nil Helpers.parse_time("")
      end

      test "parse_time parses timestamps in the application time zone" do
        assert_equal Time.zone.parse("2022-06-19 09:25:40"), Helpers.parse_time("2022-06-19 09:25:40")
      end

      test "parse_time returns nil for unparseable and out-of-range timestamps" do
        assert_nil Helpers.parse_time("not a timestamp")
        assert_nil Helpers.parse_time("2022-13-45 09:25:40")
      end

      test "parse_bool recognises PostgreSQL and literal true values" do
        assert Helpers.parse_bool("t")
        assert Helpers.parse_bool("true")
        assert_not Helpers.parse_bool("f")
        assert_not Helpers.parse_bool(nil)
      end

      test "to_int converts strings and treats NULL-like values as nil" do
        assert_equal 42, Helpers.to_int("42")
        assert_nil Helpers.to_int(nil)
        assert_nil Helpers.to_int('\N')
        assert_nil Helpers.to_int("")
      end

      test "progress prints the counter and a newline only when finished" do
        assert_output("\r  Books: 1/2") { Helpers.progress(1, 2, "Books") }
        assert_output("\r  Books: 2/2\n") { Helpers.progress(2, 2, "Books") }
      end
    end
  end
end
