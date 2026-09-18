# frozen_string_literal: true

require "test_helper"

class BlockBannedRequestsTest < ActionDispatch::IntegrationTest
  test "requests from a banned IP address are denied" do
    Ban.create!(ip_address: "127.0.0.1", reason: "Abuse")

    get root_path

    assert_response :forbidden
    assert_equal "Access denied", response.body
  end

  test "requests from an IP whose ban has expired are allowed" do
    Ban.create!(ip_address: "127.0.0.1", reason: "Abuse", expires_at: 1.hour.ago)

    get root_path

    assert_response :success
  end

  test "requests from a signed in user who was suspended are denied" do
    post session_url, params: { email_address: "editor@test.com", password: "password" }
    get root_path
    assert_response :success

    users(:editor).suspended!

    get root_path

    assert_response :forbidden
    assert_equal "Access denied", response.body
  end
end
