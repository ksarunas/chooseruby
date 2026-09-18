# frozen_string_literal: true

require "test_helper"

class CategorySlugTest < ActiveSupport::TestCase
  test "appends a counter when the generated slug is already taken" do
    Category.create!(name: "Ruby Testing")
    second = Category.create!(name: "Ruby-Testing")
    third = Category.create!(name: "Ruby  Testing")

    assert_equal "ruby-testing-1", second.slug
    assert_equal "ruby-testing-2", third.slug
  end
end
