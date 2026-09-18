# frozen_string_literal: true

require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "GET why_ruby renders the pillars and modern highlights" do
    get why_ruby_path

    assert_response :success
    assert_select "*", text: /Velocity without the overhead/
    assert_select "*", text: /Rails 8 \+ Hotwire/
  end

  test "GET mission renders the mission points and personas" do
    get mission_path

    assert_response :success
    assert_select "*", text: /Surface the best of Ruby/
    assert_select "*", text: /Sarah/
  end

  test "GET roadmap renders the MVP tracks and phases" do
    get roadmap_path

    assert_response :success
    assert_select "*", text: /Searchable directory/
    assert_select "*", text: /Phase 1: Foundation/
  end
end
