# frozen_string_literal: true

require "test_helper"

class EntryDirectoryQuerySortTest < ActiveSupport::TestCase
  setup do
    ActiveRecord::Base.connection.execute("DELETE FROM entries_fts")
    Entry.destroy_all
    RubyGem.destroy_all
    Community.destroy_all

    popular_gem = RubyGem.create!(gem_name: "sort-popular", downloads_count: 5_000)
    @popular = Entry.create!(
      title: "Popular Gem", url: "https://example.com/popular", entryable: popular_gem,
      experience_level: :advanced, status: :approved, published: true, updated_at: 3.days.ago
    )

    community = Community.create!(platform: "Slack", join_url: "https://example.com/slack", member_count: 50)
    @community = Entry.create!(
      title: "Ruby Community", url: "https://example.com/community", entryable: community,
      experience_level: :intermediate, status: :approved, published: true, updated_at: 2.days.ago
    )

    @plain = Entry.create!(
      title: "Beginner Guide", url: "https://example.com/beginner",
      experience_level: :beginner, status: :approved, published: true, updated_at: 1.day.ago
    )
  end

  teardown do
    ActiveRecord::Base.connection.execute("DELETE FROM entries_fts")
    Entry.destroy_all
    RubyGem.destroy_all
    Community.destroy_all
  end

  test "popular sort orders by downloads, members and episodes" do
    assert_equal [ @popular, @community, @plain ], EntryDirectoryQuery.new({ sort: "popular" }).call.to_a
  end

  test "oldest sort orders by least recently updated" do
    assert_equal [ @popular, @community, @plain ], EntryDirectoryQuery.new({ sort: "oldest" }).call.to_a
  end

  test "beginner_first sort orders by experience level" do
    assert_equal [ @plain, @community, @popular ], EntryDirectoryQuery.new({ sort: "beginner_first" }).call.to_a
  end

  test "unknown sort falls back to most recently updated" do
    query = EntryDirectoryQuery.new({ sort: "bogus" })

    assert_equal "bogus", query.sort
    assert_equal [ @plain, @community, @popular ], query.call.to_a
  end

  test "unknown sort keeps FTS relevance ordering when searching" do
    results = EntryDirectoryQuery.new({ sort: "bogus", q: "ruby" }).call

    assert_equal [ @community ], results.to_a
  end

  test "unknown experience level is ignored" do
    query = EntryDirectoryQuery.new({ level: "expert" })

    assert_equal "expert", query.level
    assert_equal 3, query.call.count
  end

  test "search words made only of special characters are dropped" do
    results = EntryDirectoryQuery.new({ q: "beginner -" }).call

    assert_equal [ @plain ], results.to_a
  end
end
