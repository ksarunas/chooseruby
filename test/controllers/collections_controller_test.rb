# frozen_string_literal: true

require "test_helper"

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  test "GET index lists the curated collections" do
    get collections_path

    assert_response :success
    assert_select "a[href=?]", collection_path("hotwire-speed")
  end

  test "GET show renders a curated collection with its base filters" do
    entry = Entry.create!(title: "Hotwire Handbook", url: "https://example.com/hotwire", description: "Turbo and Stimulus guide", published: true, status: :approved)

    get collection_path("hotwire-speed")

    assert_response :success
    assert_select "a[href=?]", resource_path(entry.slug)
  end

  test "GET show keeps base filters when override params are blank" do
    Entry.create!(title: "Hotwire Handbook", url: "https://example.com/hotwire", description: "Turbo and Stimulus guide", published: true, status: :approved)

    get collection_path("hotwire-speed"), params: { q: "" }

    assert_response :success
    assert_select "h3", text: "Hotwire Handbook"
  end

  test "GET show lets present override params replace base filters" do
    Entry.create!(title: "Hotwire Handbook", url: "https://example.com/hotwire", description: "Turbo and Stimulus guide", published: true, status: :approved)
    Entry.create!(title: "Sidekiq Deep Dive", url: "https://example.com/sidekiq", description: "Background jobs", published: true, status: :approved)

    get collection_path("hotwire-speed"), params: { q: "sidekiq" }

    assert_response :success
    assert_select "h3", text: "Sidekiq Deep Dive"
    assert_select "h3", text: "Hotwire Handbook", count: 0
  end

  test "GET show returns 404 for an unknown collection" do
    get collection_path("does-not-exist")

    assert_response :not_found
  end
end
