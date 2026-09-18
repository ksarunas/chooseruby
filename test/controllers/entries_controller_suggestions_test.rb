# frozen_string_literal: true

require "test_helper"

class EntriesControllerSuggestionsTest < ActionDispatch::IntegrationTest
  test "GET suggestions returns an empty body for queries shorter than two characters" do
    get entries_suggestions_path, params: { q: "t" }

    assert_response :ok
    assert_empty response.body
  end

  test "GET suggestions renders matching entries, categories and types" do
    Category.find_or_create_by!(name: "Testing") { |c| c.slug = "testing" }
    Entry.create!(title: "Testing Rails Apps", url: "https://example.com/testing", published: true, status: :approved)
    Entry.create!(title: "Hidden Testing Guide", url: "https://example.com/hidden", published: false, status: :approved)

    get entries_suggestions_path, params: { q: "test" }

    assert_response :success
    assert_select "span", text: "Testing Rails Apps"
    assert_select "span", text: "Hidden Testing Guide", count: 0
    assert_select "[role=listbox]"
  end

  test "GET suggestions escapes LIKE wildcards in the query" do
    Entry.create!(title: "Percent Sign Guide", url: "https://example.com/percent", published: true, status: :approved)

    get entries_suggestions_path, params: { q: "%%" }

    assert_response :success
    assert_select "span", text: "Percent Sign Guide", count: 0
  end
end

class EntriesControllerCreateEdgeCasesTest < ActionDispatch::IntegrationTest
  test "POST create ignores an author_id that does not match an author" do
    assert_difference "Entry.count", 1 do
      post entries_path, params: {
        entry: {
          title: "Orphan Gem",
          url: "https://example.com/orphan",
          description: "No author here",
          resource_type: "RubyGem",
          submitter_email: "submitter@example.com",
          gem_name: "orphan",
          author_id: 999_999
        }
      }
    end

    assert_redirected_to entry_success_path
    assert_empty Entry.last.authors
  end

  test "POST create with Course type stores the price in cents only when a price is given" do
    post entries_path, params: {
      entry: {
        title: "Free Rails Course",
        url: "https://example.com/free-course",
        description: "A free course",
        resource_type: "Course",
        submitter_email: "submitter@example.com",
        platform: "YouTube"
      }
    }
    assert_redirected_to entry_success_path
    assert_nil Course.last.price_cents

    post entries_path, params: {
      entry: {
        title: "Paid Rails Course",
        url: "https://example.com/paid-course",
        description: "A paid course",
        resource_type: "Course",
        submitter_email: "submitter@example.com",
        platform: "Udemy",
        price: "19.99"
      }
    }
    assert_redirected_to entry_success_path
    assert_equal 1999, Course.last.price_cents
  end

  test "POST create with an unknown resource type raises an ArgumentError" do
    error = assert_raises(ArgumentError) do
      post entries_path, params: {
        entry: {
          title: "Mystery Resource",
          url: "https://example.com/mystery",
          description: "Unknown type",
          resource_type: "Mystery",
          submitter_email: "submitter@example.com"
        }
      }
    end

    assert_equal "Unknown resource type: Mystery", error.message
  end
end
