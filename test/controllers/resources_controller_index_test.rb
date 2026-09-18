# frozen_string_literal: true

require "test_helper"

class ResourcesControllerIndexTest < ActionDispatch::IntegrationTest
  test "GET index lists visible entries and featured resources" do
    featured = Entry.create!(title: "Featured Gem", url: "https://example.com/featured", published: true, status: :approved, featured_at: 1.day.ago)
    regular = Entry.create!(title: "Regular Gem", url: "https://example.com/regular", published: true, status: :approved)
    Entry.create!(title: "Draft Gem", url: "https://example.com/draft", published: false, status: :approved)

    get resources_path

    assert_response :success
    assert_select "a[href=?]", resource_path(featured.slug)
    assert_select "a[href=?]", resource_path(regular.slug)
    assert_select "a", text: "Draft Gem", count: 0
  end

  test "GET index applies search, level and type filters" do
    ruby_gem = RubyGem.create!(gem_name: "rspec")
    Entry.create!(title: "RSpec Basics", url: "https://example.com/rspec", published: true, status: :approved, experience_level: "beginner", entryable: ruby_gem)
    Entry.create!(title: "Advanced Minitest", url: "https://example.com/minitest", published: true, status: :approved, experience_level: "advanced")

    get resources_path, params: { q: "rspec", level: "beginner", type: "gems" }

    assert_response :success
    assert_select "h3", text: "RSpec Basics"
    assert_select "h3", text: "Advanced Minitest", count: 0
  end
end

class ResourcesControllerRelatedByTopicTest < ActionDispatch::IntegrationTest
  test "GET show does not backfill related resources by type when the topic already yields five" do
    category = Category.find_or_create_by!(name: "Testing") { |c| c.slug = "testing" }
    tool = Tool.create!(tool_type: "CLI")
    entry = Entry.create!(title: "Primary Testing Entry", url: "https://example.com/primary", published: true, status: :approved, entryable: tool)
    entry.categories << category

    5.times do |index|
      related = Entry.create!(title: "Topic Related #{index}", url: "https://example.com/topic-#{index}", published: true, status: :approved)
      related.categories << category
    end
    other_tool = Tool.create!(tool_type: "CLI")
    Entry.create!(title: "Same Type Only", url: "https://example.com/same-type", published: true, status: :approved, entryable: other_tool)

    get "/resources/#{entry.slug}"

    assert_response :success
    5.times { |index| assert_select "a", text: "Topic Related #{index}" }
    assert_select "a", text: "Same Type Only", count: 0
  end
end
