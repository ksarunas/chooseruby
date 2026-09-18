# frozen_string_literal: true

require "test_helper"

module Imports
  module Rubyandrailsinfo
    class IdMapperTest < ActiveSupport::TestCase
      setup { @mapper = IdMapper.new }

      test "maps old category ids to categories regardless of id type" do
        category = Category.new(name: "Testing")

        @mapper.register_category(5, category)

        assert_same category, @mapper.find_category("5")
        assert_nil @mapper.find_category(6)
      end

      test "maps old author ids to authors regardless of id type" do
        author = Author.new(name: "Matz")

        @mapper.register_author("9", author)

        assert_same author, @mapper.find_author(9)
        assert_nil @mapper.find_author(10)
      end

      test "maps old polymorphic references to entries" do
        entry = Entry.new(title: "Mapped")

        @mapper.register_entry("Book", 1, entry)

        assert_same entry, @mapper.find_entry("Book", 1)
        assert_nil @mapper.find_entry("Course", 1)
        assert_nil @mapper.find_entry("Book", 2)
      end

      test "stats counts registered mappings per kind" do
        assert_equal({ categories: 0, authors: 0, entries: 0 }, @mapper.stats)

        @mapper.register_category(1, Category.new)
        @mapper.register_author(1, Author.new)
        @mapper.register_author(2, Author.new)
        @mapper.register_entry("Book", 1, Entry.new)

        assert_equal({ categories: 1, authors: 2, entries: 1 }, @mapper.stats)
      end
    end
  end
end
