# frozen_string_literal: true

require "test_helper"

# Covers the Avo `display_name` helper on every delegated type that has one.
# Book is covered separately in book_display_name_test.rb.
class EntryableDisplayNameTest < ActiveSupport::TestCase
  # Types whose display_name falls back straight from the entry title to "<Type> #id"
  ENTRY_TITLE_TYPES = {
    Article => {},
    Community => { platform: "Discord", join_url: "https://discord.gg/ruby" },
    Course => {},
    Podcast => {},
    Tool => {},
    Tutorial => {}
  }.freeze

  # Types that carry their own required `name`, then fall back to the entry title, then "<Type> #id"
  NAMED_TYPES = [
    Blog, Channel, DevelopmentEnvironment, Directory, Documentation, Framework,
    JobBoard, Newsletter, Product, TestingResource, Video
  ].freeze

  ENTRY_TITLE_TYPES.each do |klass, attributes|
    test "#{klass.name} display_name returns the entry title when an entry exists" do
      entryable = klass.new(attributes)
      entryable.entry = Entry.new(title: "Some #{klass.name} Title", url: "https://example.com")

      assert_equal "Some #{klass.name} Title", entryable.display_name
    end

    test "#{klass.name} display_name falls back to type and id without an entry" do
      entryable = klass.create!(attributes)

      assert_equal "#{klass.name} ##{entryable.id}", entryable.display_name
    end
  end

  NAMED_TYPES.each do |klass|
    test "#{klass.name} display_name prefers its own name" do
      entryable = klass.new(name: "Own Name")
      entryable.entry = Entry.new(title: "Entry Title", url: "https://example.com")

      assert_equal "Own Name", entryable.display_name
    end

    test "#{klass.name} display_name uses the entry title when name is blank" do
      entryable = klass.new(name: "")
      entryable.entry = Entry.new(title: "Entry Title", url: "https://example.com")

      assert_equal "Entry Title", entryable.display_name
    end

    test "#{klass.name} display_name falls back to type and id when name and entry are missing" do
      entryable = klass.create!(name: "Persisted Name")
      entryable.name = nil

      assert_equal "#{klass.name} ##{entryable.id}", entryable.display_name
    end
  end

  test "RubyGem display_name returns the entry title when an entry exists" do
    ruby_gem = RubyGem.new(gem_name: "rspec")
    ruby_gem.entry = Entry.new(title: "RSpec", url: "https://rspec.info")

    assert_equal "RSpec", ruby_gem.display_name
  end

  test "RubyGem display_name falls back to gem_name without an entry" do
    ruby_gem = RubyGem.new(gem_name: "rspec")

    assert_equal "rspec", ruby_gem.display_name
  end

  test "RubyGem display_name falls back to type and id when gem_name and entry are missing" do
    ruby_gem = RubyGem.create!(gem_name: "display-name-fallback")
    ruby_gem.gem_name = nil

    assert_equal "RubyGem ##{ruby_gem.id}", ruby_gem.display_name
  end
end
