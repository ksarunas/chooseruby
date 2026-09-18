# frozen_string_literal: true

require "test_helper"

class AnnotateRbRakeTest < ActiveSupport::TestCase
  RAKE_FILE = Rails.root.join("lib/tasks/annotate_rb.rake")

  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("db:migrate")
  end

  test "hooks annotate_rb into the migration tasks in development" do
    with_rails_env("development") { load RAKE_FILE }

    annotate_hooks = Rake::Task["db:migrate"].actions.select do |action|
      action.source_location.first.include?("/annotaterb-")
    end
    assert_equal 1, annotate_hooks.size
  end

  private

  def with_rails_env(name)
    original_env = Rails.env
    Rails.env = name
    yield
  ensure
    Rails.env = original_env
  end
end
