# frozen_string_literal: true

require "test_helper"

class CommunitiesControllerTest < ActionDispatch::IntegrationTest
  test "GET index lists communities with official ones first" do
    unofficial = Community.create!(platform: "Discord", join_url: "https://discord.gg/ruby", member_count: 500, is_official: false)
    official = Community.create!(platform: "Slack", join_url: "https://slack.com/ruby", member_count: 100, is_official: true)

    get communities_path

    assert_response :success
    assert_select "h3", text: "#{official.platform} community"
    assert_select "h3", text: "#{unofficial.platform} community"
    assert_operator response.body.index("Slack community"), :<, response.body.index("Discord community")
  end

  test "GET index renders when there are no communities" do
    get communities_path

    assert_response :success
  end
end
