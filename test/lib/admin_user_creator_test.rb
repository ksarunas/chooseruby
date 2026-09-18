# frozen_string_literal: true

require "test_helper"

class AdminUserCreatorTest < ActiveSupport::TestCase
  # Stands in for $stdin: answers prompts in order and supports IO::console's noecho.
  class FakeConsole
    def initialize(*answers)
      @answers = answers.map { |answer| "#{answer}\n" }
    end

    def gets
      @answers.shift
    end

    def noecho
      yield self
    end
  end

  setup { @output = StringIO.new }

  test "creates an active admin user from the console answers" do
    console = FakeConsole.new("new-admin@example.com", "New Admin", "secret123", "secret123")

    assert_difference("User.count", 1) do
      AdminUserCreator.new(input: console, output: @output).call
    end

    user = User.find_by!(email_address: "new-admin@example.com")
    assert_equal "New Admin", user.name
    assert_predicate user, :admin?
    assert_predicate user, :active?
    assert user.authenticate("secret123")
    assert_includes @output.string, "Email address: Name: Password: \nConfirm password: \n"
    assert_includes @output.string, "Successfully created admin user: New Admin\nEmail: new-admin@example.com\n"
  end

  test "exits without creating a user when the passwords differ" do
    console = FakeConsole.new("new-admin@example.com", "New Admin", "secret123", "different")

    assert_no_difference("User.count") do
      error = assert_raises(SystemExit) { AdminUserCreator.new(input: console, output: @output).call }
      assert_equal 1, error.status
    end

    assert_includes @output.string, "Error: Passwords don't match"
  end

  test "exits listing the validation errors when the user is invalid" do
    console = FakeConsole.new("not-an-email", "", "secret123", "secret123")

    assert_no_difference("User.count") do
      error = assert_raises(SystemExit) { AdminUserCreator.new(input: console, output: @output).call }
      assert_equal 1, error.status
    end

    assert_includes @output.string, "Failed to create user:"
    assert_includes @output.string, "  - Email address is invalid"
    assert_includes @output.string, "  - Name can't be blank"
  end
end
