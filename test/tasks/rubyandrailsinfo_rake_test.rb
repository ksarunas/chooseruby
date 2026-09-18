# frozen_string_literal: true

require "test_helper"
require_relative "../support/singleton_stubs"

class RubyandrailsinfoRakeTest < ActiveSupport::TestCase
  include SingletonStubs

  class FakeImportStep
    attr_reader :calls

    def initialize
      @calls = []
    end

    def convert_all = @calls << :convert_all
    def import_all = @calls << :import_all
  end

  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("rubyandrailsinfo:sql_to_yaml")
    @step = FakeImportStep.new
    @captured = {}
    step = @step
    captured = @captured
    @capture_new = ->(**arguments) { captured[:arguments] = arguments; step }
  end

  test "rubyandrailsinfo:sql_to_yaml converts tmp/latest.sql into data/rubyandrailsinfo" do
    stub_singleton(Imports::Rubyandrailsinfo::SqlToYamlConverter, :new, @capture_new) do
      run_task("rubyandrailsinfo:sql_to_yaml")
    end

    assert_equal [ :convert_all ], @step.calls
    assert_equal({ sql_file: Rails.root.join("tmp/latest.sql"), output_dir: Rails.root.join("data/rubyandrailsinfo") },
                 @captured[:arguments])
  end

  test "rubyandrailsinfo:yaml_to_db imports data/rubyandrailsinfo" do
    stub_singleton(Imports::Rubyandrailsinfo::YamlImporter, :new, @capture_new) do
      run_task("rubyandrailsinfo:yaml_to_db")
    end

    assert_equal [ :import_all ], @step.calls
    assert_equal({ yaml_dir: Rails.root.join("data/rubyandrailsinfo") }, @captured[:arguments])
  end

  private

  def run_task(name)
    Rake::Task[name].reenable
    Rake::Task[name].invoke
  end
end
