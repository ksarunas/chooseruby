# frozen_string_literal: true

require "test_helper"

class ExperienceLevelTest < ActiveSupport::TestCase
  test "returns emerald-500 for beginner level" do
    assert_equal "bg-emerald-500", ExperienceLevel["beginner"].badge_color
  end

  test "returns amber-500 for intermediate level" do
    assert_equal "bg-amber-500", ExperienceLevel["intermediate"].badge_color
  end

  test "returns rose-500 for advanced level" do
    assert_equal "bg-rose-500", ExperienceLevel["advanced"].badge_color
  end

  test "returns slate-500 for all_levels" do
    assert_equal "bg-slate-500", ExperienceLevel["all_levels"].badge_color
  end

  test "returns slate-500 for unknown level" do
    assert_equal "bg-slate-500", ExperienceLevel["unknown"].badge_color
  end
end
