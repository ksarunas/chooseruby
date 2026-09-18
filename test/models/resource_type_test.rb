# frozen_string_literal: true

require "test_helper"

class ResourceTypeTest < ActiveSupport::TestCase
  # Test 1: type_name returns correct names for new types
  test "type_name returns correct names for new resource types" do
    assert_equal "Newsletters", ResourceType["newsletters"].name
    assert_equal "Blogs", ResourceType["blogs"].name
    assert_equal "Videos", ResourceType["videos"].name
    assert_equal "Testing Resources", ResourceType["testing-resources"].name
    assert_equal "Development Environments", ResourceType["development-environments"].name
  end

  # Test 2: type_emoji returns correct emojis for new types
  test "type_emoji returns correct emojis for new resource types" do
    assert_equal "📧", ResourceType["newsletters"].emoji
    assert_equal "📝", ResourceType["blogs"].emoji
    assert_equal "🎥", ResourceType["videos"].emoji
    assert_equal "📺", ResourceType["channels"].emoji
    assert_equal "📚", ResourceType["documentations"].emoji
    assert_equal "🧪", ResourceType["testing-resources"].emoji
    assert_equal "💻", ResourceType["development-environments"].emoji
    assert_equal "💼", ResourceType["job-boards"].emoji
    assert_equal "🏗️", ResourceType["frameworks"].emoji
    assert_equal "📂", ResourceType["directories"].emoji
    assert_equal "🚀", ResourceType["products"].emoji
  end

  # Test 3: type_description returns correct descriptions for new types
  test "type_description returns correct descriptions for new resource types" do
    assert_equal "curated newsletters for Ruby developers", ResourceType["newsletters"].description
    assert_equal "curated blogs for Ruby developers", ResourceType["blogs"].description
    assert_equal "curated videos for Ruby developers", ResourceType["videos"].description
    assert_equal "curated testing resources for Ruby developers", ResourceType["testing-resources"].description
    assert_equal "curated development environments for Ruby developers", ResourceType["development-environments"].description
  end

  # Test 4: submission_message_for_type returns correct message for newsletter (singular)
  test "submission_message_for_type returns correct message for newsletter" do
    message = ResourceType["newsletters"].submission_message
    assert_includes message, "Know a great Ruby newsletter?"
    assert_includes message, "Submit it here"
  end

  # Test 5: submission_message_for_type returns correct message for videos (plural)
  test "submission_message_for_type returns correct message for videos" do
    message = ResourceType["videos"].submission_message
    assert_includes message, "Know a great Ruby video?"
    assert_includes message, "Submit it here"
  end

  # Test 6: submission_message_for_type returns correct message for testing resources
  test "submission_message_for_type returns correct message for testing resources" do
    message = ResourceType["testing-resources"].submission_message
    assert_includes message, "Know a great Ruby testing resource?"
    assert_includes message, "Submit it here"
  end

  # Test 7: type_name falls back to titleize for unknown types
  test "type_name falls back to titleize for unknown types" do
    assert_equal "Unknown Type", ResourceType["unknown-type"].name
  end

  # Test 8: type_emoji falls back to default emoji for unknown types
  test "type_emoji falls back to default emoji for unknown types" do
    assert_equal "📦", ResourceType["unknown-type"].emoji
  end
end
