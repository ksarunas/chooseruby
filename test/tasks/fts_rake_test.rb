# frozen_string_literal: true

require "test_helper"
require_relative "../support/singleton_stubs"

class FtsRakeTest < ActiveSupport::TestCase
  include SingletonStubs

  class FakeReindexer
    attr_reader :calls

    def initialize
      @calls = []
    end

    def reindex_all = @calls << :reindex_all
    def reindex_entries = @calls << :reindex_entries
    def reindex_authors = @calls << :reindex_authors
  end

  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?("fts:create")
    @reindexer = FakeReindexer.new
  end

  test "fts:create ensures the FTS5 tables exist" do
    output, = capture_io { run_task("fts:create") }

    assert_includes output, "Creating FTS5 virtual tables..."
    assert_includes output, "FTS5 tables ready!"
    assert_includes fts_table_names, "entries_fts"
  end

  test "fts:reindex_all delegates to FtsReindexer" do
    output, = with_fake_reindexer { run_task("fts:reindex_all") }

    assert_equal [ :reindex_all ], @reindexer.calls
    assert_equal "Reindexing all FTS5 tables...\nReindexing completed successfully!\n", output
  end

  test "fts:reindex_entries delegates to FtsReindexer" do
    output, = with_fake_reindexer { run_task("fts:reindex_entries") }

    assert_equal [ :reindex_entries ], @reindexer.calls
    assert_equal "Reindexing entries FTS5 table...\nEntries reindexing completed!\n", output
  end

  test "fts:reindex_authors delegates to FtsReindexer" do
    output, = with_fake_reindexer { run_task("fts:reindex_authors") }

    assert_equal [ :reindex_authors ], @reindexer.calls
    assert_equal "Reindexing authors FTS5 table...\nAuthors reindexing completed!\n", output
  end

  test "db:test:prepare is enhanced to create the FTS5 tables afterwards" do
    enhancement = Rake::Task["db:test:prepare"].actions.select do |action|
      action.source_location.first.end_with?("lib/tasks/fts.rake")
    end
    assert_equal 1, enhancement.size

    Rake::Task["fts:create"].reenable
    output, = capture_io { enhancement.first.call }

    assert_includes output, "FTS5 tables ready!"
  end

  private

  def fts_table_names
    ActiveRecord::Base.connection.select_values("SELECT name FROM sqlite_master WHERE type = 'table' AND name LIKE '%_fts'")
  end

  def run_task(name)
    Rake::Task[name].reenable
    Rake::Task[name].invoke
  end

  def with_fake_reindexer(&block)
    reindexer = @reindexer
    stub_singleton(FtsReindexer, :new, -> { reindexer }) { capture_io(&block) }
  end
end
