# frozen_string_literal: true

require "test_helper"

class UserRoleTest < ActiveSupport::TestCase
  test "can_administer? is true for admins" do
    assert users(:admin).can_administer?
  end

  test "can_administer? is false for editors" do
    assert_not users(:editor).can_administer?
  end
end
