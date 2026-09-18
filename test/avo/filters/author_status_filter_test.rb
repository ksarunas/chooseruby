# frozen_string_literal: true

require "test_helper"

class Avo::Filters::AuthorStatusFilterTest < ActiveSupport::TestCase
  setup do
    @filter = Avo::Filters::AuthorStatusFilter.new
    @approved = Author.create!(name: "Approved Author", status: :approved)
    @pending = Author.create!(name: "Pending Author", status: :pending)
  end

  test "filters authors by status" do
    assert_equal [ @approved ], @filter.apply(nil, Author.all, "approved").to_a
    assert_equal [ @pending ], @filter.apply(nil, Author.all, "pending").to_a
  end

  test "returns the query untouched for unknown values" do
    query = Author.all

    assert_same query, @filter.apply(nil, query, "rejected")
  end

  test "offers approved and pending options" do
    assert_equal({ "Approved" => "approved", "Pending" => "pending" }, @filter.options)
  end
end
