# frozen_string_literal: true

require "test_helper"

class UserBannableTest < ActiveSupport::TestCase
  setup do
    @user = users(:editor)
  end

  test "ban! records a ban, suspends the user and closes all sessions" do
    @user.sessions.create!(token: SecureRandom.urlsafe_base64(32), last_active_at: Time.current)
    expires_at = 3.days.from_now

    assert_difference -> { @user.bans.count }, 1 do
      @user.ban!(reason: "Spam", ip_address: "10.0.0.1", expires_at: expires_at)
    end

    ban = @user.bans.last
    assert_equal "Spam", ban.reason
    assert_equal "10.0.0.1", ban.ip_address
    assert_in_delta expires_at, ban.expires_at, 1.second
    assert_predicate @user, :suspended?
    assert_predicate @user, :banned?
    assert_equal 0, @user.sessions.count
  end

  test "unban! expires active bans and reactivates the user" do
    user = users(:suspended)
    active_ban = bans(:active_ban)

    user.unban!

    assert_predicate user, :active?
    assert_not user.banned?
    assert_operator active_ban.reload.expires_at, :<=, Time.current
    assert_empty user.bans.active
  end

  test "banned? is false for an active user" do
    assert_not @user.banned?
  end
end
