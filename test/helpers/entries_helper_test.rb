# frozen_string_literal: true

require "test_helper"

class EntriesHelperTest < ActionView::TestCase
  test "experience_level_options_for_select excludes all_levels but includes other levels" do
    html = experience_level_options_for_select

    assert_includes html, "Beginner"
    assert_includes html, "Intermediate"
    assert_includes html, "Advanced"
    assert_not_includes html, "All levels"
  end
end
