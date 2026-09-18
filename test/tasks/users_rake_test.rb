# frozen_string_literal: true

require "test_helper"
require_relative "../support/singleton_stubs"

class UsersRakeTest < ActiveSupport::TestCase
  include SingletonStubs

  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("users:create_admin")
  end

  test "users:create_admin delegates to AdminUserCreator" do
    calls = []
    creator = Object.new
    creator.define_singleton_method(:call) { calls << :call }

    stub_singleton(AdminUserCreator, :new, -> { creator }) do
      Rake::Task["users:create_admin"].reenable
      Rake::Task["users:create_admin"].invoke
    end

    assert_equal [ :call ], calls
  end
end
